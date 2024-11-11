//
//  AccessibilityElement.swift
//  Macnium
//
//  Created by Wttch on 2024/11/10.
//

import AppKit

struct AccessibilityElement {
    let element: AXUIElement
}

extension AccessibilityElement {
    /// 创建一个辅助功能对象，以提供对系统属性的访问
    init() {
        self.element = AXUIElementCreateSystemWide()
    }

    init(_ element: AXUIElement) {
        self.element = element
    }

    /// 使用具有指定运行应用程序的辅助功能对象创建顶级辅助功能对象
    init?(application: NSRunningApplication) {
        self.init(pid: application.processIdentifier)
    }

    /// 使用具有指定 bundle identifier 的应用程序创建顶级辅助功能对象
    init?(withBundleIdentifier: String) {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: withBundleIdentifier).first else {
            return nil
        }

        self.init(pid: app.processIdentifier)
    }

    /// 使用具有指定进程 ID 的应用程序创建顶级辅助功能对象
    /// - Parameter
    ///    - pid: 应用程序的进程 ID
    init(pid: pid_t) {
        self.element = AXUIElementCreateApplication(pid)
    }

    /// 获取当前辅助功能对象的属性值
    /// - Parameter attribute: 属性键
    /// - Throws: 如果无法检索属性值, 或者类型不匹配, 则抛出错误
    /// - Returns: 属性值
    private func attribute<T>(_ attribute: AccessibilityElementAttributeKey<T>) -> T? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute.key as CFString, &value)
        guard result == .success else {
            return nil
        }
        guard let value = value as? T else {
            return nil
        }
        return value
    }
}

// MARK: - 属性获取

extension AccessibilityElement {
    /// 返回与当前辅助功能对象相关联的进程ID
    /// - Throws: 如果无法检索进程ID，则抛出错误
    /// - Returns: 与当前辅助功能对象相关联的进程ID
    var pid: pid_t? {
        get throws {
            var pid: pid_t = 0
            let result = AXUIElementGetPid(element, &pid)
            guard result == .success else { return nil }
            return pid
        }
    }

    var windows: [Self] {
        guard let windows = attribute(.windows) else {
            return []
        }
        return windows.map { Self($0) }
    }

    var children: [Self] {
        guard let children = attribute(.children) else {
            return []
        }
        return children.map { Self($0) }
    }

    var role: String? {
        attribute(.role)
    }

    var description: String? {
        attribute(.description)
    }
    
    var title: String? {
        attribute(.title)
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
        let result = AXUIElementPerformAction(element, action.action)
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
