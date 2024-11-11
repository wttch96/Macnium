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
struct AccessibilityElement: @unchecked Sendable {
    let original: AXUIElement

    let title: String?
    let description: String?

    let children: [AccessibilityElement]

    init(_ element: AXUIElement) {
        self.original = element

        // 拼装属性
        self.children = original.attribute(.children)?.map { AccessibilityElement($0) } ?? []
        self.title = original.attribute(.title)
        self.description = original.attribute(.description)
    }
}

/// - seeAlso: [Roles](https://developer.apple.com/documentation/appkit/nsaccessibility/role)

// MARK: - 计算属性的获取

extension AccessibilityElement {
    /// 创建一个辅助功能对象，以提供对系统属性的访问
    init() {
        self.init(AXUIElementCreateSystemWide())
    }

    /// 获取当前辅助功能对象的属性值
    /// - Parameter attribute: 属性键
    /// - Throws: 如果无法检索属性值, 或者类型不匹配, 则抛出错误
    /// - Returns: 属性值
    private func attribute<T>(_ attribute: AccessibilityElementAttributeKey<T>) throws -> T? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(original, attribute.key as CFString, &value)

        if error == .noValue || error == .attributeUnsupported {
            return nil
        }

        guard error == .success else {
            throw AccessibilityError.error(error)
        }
        guard let value = value as? T else {
            throw AccessibilityError.unexpectedTypeError(expected: T.self, actual: type(of: value))
        }
        return value
    }

    private func arrayAttribute<T>(_ attributes: AccessibilityElementAttributeKey<[T]>) throws -> [T] {
        return try attribute(attributes) ?? []
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
            guard let role = AccessibilityRole(rawValue: original.attribute(.role)!) else {
                throw AccessibilityError.logicError("无法识别的辅助功能对象类型")
            }
            return role
        }
    }

    var allowedValues: [Any] {
        get throws {
            try arrayAttribute(.allowedValues)
        }
    }

    var windows: [Self] {
        get throws {
            try arrayAttribute(.windows).map(AccessibilityElement.init)
        }
    }

    var parent: Self? {
        get throws {
            try attribute(.parent).map { AccessibilityElement($0) }
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
    func find(_ condition: (AccessibilityElement) -> Bool) -> AccessibilityElement? {
        if condition(self) {
            return self
        }
        for child in children {
            if let element = child.find(condition) {
                return element
            }
        }
        return nil
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

    func attribute<T>(_ attribute: AccessibilityElementAttributeKey<T>) -> T? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(self, attribute.key as CFString, &value)
        guard result == .success else {
            return nil
        }
        guard let value = value as? T else {
            return nil
        }
        return value
    }
}
