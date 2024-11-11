//
//  AccessibilityElement.swift
//  Macnium
//
//  本文件主要是对 AXUIElement 对象的封装
//
//  Created by Wttch on 2024/11/10.
//

import AppKit

/// 对 `AXUIElement` 进行封装
struct AccessibilityElement: CustomStringConvertible, @unchecked Sendable {
    let original: AXUIElement

    var children: [AccessibilityElement] {
        get throws {
            try original.attribute(.children)?.map { try AccessibilityElement($0) } ?? []
        }
    }

    init(_ element: AXUIElement) throws {
        self.original = element
    }

    var description: String {
        do {
            return try "[\(role)]: \(self.description0)"
        } catch {
            return error.localizedDescription
        }
    }
}

// MARK: - 原类型扩展

private extension AXUIElement {
    var pid: pid_t? {
        var pid: pid_t = 0
        let result = AXUIElementGetPid(self, &pid)
        guard result == .success else { return nil }
        return pid
    }

    func attributesAsStrings() throws -> [String] {
        var names: CFArray?
        let error = AXUIElementCopyAttributeNames(self, &names)

        if error == .noValue || error == .attributeUnsupported {
            return []
        }

        guard error == .success else {
            throw AccessibilityError.error(error)
        }

        return names! as! [String]
    }

    /// 获取当前辅助功能对象的属性值
    /// - Parameter attribute: 属性键
    /// - Throws: 如果无法检索属性值, 或者类型不匹配, 则抛出错误
    /// - Returns: 属性值
    func attribute<O, T>(_ attribute: AccessibilityElementAttributeKey<O, T>) throws -> T? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(self, attribute.key as CFString, &value)

        if error == .noValue || error == .attributeUnsupported {
            return nil
        }

        guard error == .success else {
            throw AccessibilityError.error(error)
        }
        guard let value = value as? O
        else {
            throw AccessibilityError.unexpectedTypeError(expected: T.self, actual: type(of: value))
        }

        return attribute.convertFunc(value)
    }

    func requiredAttribute<O, T>(_ attribute: AccessibilityElementAttributeKey<O, T>) throws -> T {
        guard let value = try self.attribute(attribute) else {
            throw AccessibilityError.logicError("属性值不存在")
        }
        return value
    }

    func requiredAttribute<O, T>(_ attribute: AccessibilityElementAttributeKey<O, [T]>) throws -> [T] {
        guard let value = try self.attribute(attribute) else {
            return []
        }
        return value
    }
}

/// - seeAlso: [Roles](https://developer.apple.com/documentation/appkit/nsaccessibility/role)

// MARK: - 计算属性的获取

extension AccessibilityElement {
    /// 创建一个辅助功能对象，以提供对系统属性的访问
    init() throws {
        try self.init(AXUIElementCreateSystemWide())
    }
}

// 这些属性相对没那么关注, 所以不会在初始化时获取, 而是在需要时获取

extension AccessibilityElement {
    var pid: pid_t? {
        original.pid
    }

    /// 角色或类型, 表示此辅助功能对象的类型(例如，AXButton).
    /// 该字符串仅用于识别目的, 无需本地化. 所有辅助功能对象必须包含此属性.
    /// - seeAlso: [Roles](https://developer.apple.com/documentation/appkit/nsaccessibility/role)
    /// - seeAlso: [kaxroleattribute](https://developer.apple.com/documentation/applicationservices/kaxroleattribute)
    var role: AccessibilityRole {
        get throws {
            try original.requiredAttribute(.role)
        }
    }

    var title: String? {
        get throws {
            try original.attribute(.title)
        }
    }

    var description0: String? {
        get throws {
            try original.attribute(.description)
        }
    }

    var allowedValues: [Any] {
        get throws {
            try original.requiredAttribute(.allowedValues)
        }
    }

    var windows: [Self] {
        get throws {
            try original.requiredAttribute(.windows).map { try AccessibilityElement($0) }
        }
    }

    var parent: Self? {
        get throws {
            try original.attribute(.parent).map { try AccessibilityElement($0) }
        }
    }
}

// MARK: - 行为

enum AccessibilityElementAction: String {
    /// 模拟单击操作, 例如点击按钮.
    case press
    /// 模拟按下 Return 键
    case confirm

    var action: CFString {
        let action = switch self {
        case .press:
            kAXPressAction
        case .confirm:
            kAXConfirmAction
        }
        return action as CFString
    }
}

extension AccessibilityElement {
    /// 模拟单击操作, 例如点击按钮.
    func perform(_ action: AccessibilityElementAction) -> Bool {
        let result = AXUIElementPerformAction(original, action.action)
        return result == .success
    }
}

// MARK: - 元素定位

extension AccessibilityElement {
    func find(_ condition: (AccessibilityElement) -> Bool) throws -> AccessibilityElement? {
        if condition(self) {
            return self
        }
        for child in try children {
            if let element = try child.find(condition) {
                return element
            }
        }
        return nil
    }
}
