//
//  AccessibilityApplication.swift
//  Macnium
//
//  Created by Wttch on 2024/11/10.
//
import AppKit

/// 具有指定运行应用程序的辅助功能对象
struct AccessibilityApplication {
    /// 元素根节点
    let root: AccessibilityElement

    /// 使用具有指定进程 ID 的应用程序创建顶级辅助功能对象
    /// - Parameter
    ///    - pid: 应用程序的进程 ID
    init(pid: pid_t) throws {
        let element = AXUIElementCreateApplication(pid)
        self.root = try AccessibilityElement(element)
    }
}

extension AccessibilityApplication {
    /// 使用具有指定运行应用程序的辅助功能对象创建顶级辅助功能对象
    init(application: NSRunningApplication) throws {
        try self.init(pid: application.processIdentifier)
    }

    /// 使用具有指定 bundle identifier 的应用程序创建顶级辅助功能对象
    init?(withBundleIdentifier: String) throws {
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: withBundleIdentifier).first else {
            return nil
        }

        try self.init(pid: app.processIdentifier)
    }

    init?(name: String) throws {
        let pid = NSWorkspace.shared.runningApplications.filter { !$0.isTerminated }
            .first { $0.localizedName?.contains(name) ?? false }?.processIdentifier
        guard let pid = pid else { return nil }
        try self.init(pid: pid)
    }
}

extension AccessibilityApplication {
    func findElement(matching predicate: (AccessibilityElement) -> Bool) throws -> AccessibilityElement? {
        return try root.find { predicate($0) }
    }

    func visit(_ element: AccessibilityElement, _ deep: Int, _ block: (AccessibilityElement, Int) throws -> Void) throws {
        try block(element, deep)
        for element in try element.children {
            try visit(element, deep + 1, block)
        }
    }
}
