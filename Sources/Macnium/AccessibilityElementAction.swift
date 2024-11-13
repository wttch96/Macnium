//
//  AccessibilityElementAction.swift
//  Macnium
//
//  Created by Wttch on 2024/11/13.
//
import ApplicationServices

/// 辅助功能对象的操作
/// - seeAlso: [action](https://developer.apple.com/documentation/applicationservices/axactionconstants_h/miscellaneous_defines)
enum AccessibilityElementAction: String {
    /// 模拟按下取消按钮
    case cancel = "AXCancel"
    /// 模拟按下 Return 键
    case confirm = "AXConfirm"
    /// 将辅助功能的值递减. 递减的幅度由 `kAXValueIncrementAttribute` 属性的值决定.
    case decrement = "AXDecrement"
    /// 将辅助功能的值递增. 递增的幅度由 `kAXValueIncrementAttribute` 属性的值决定.
    case increment = "AXIncrement"
    /// 选择 UI 元素, 例如菜单项.
    case pick = "AXPick"
    /// 模拟单击操作, 例如点击按钮.
    case press = "AXPress"
    /// 使窗口成为在当前应用程序允许的情况下最前面的窗口.
    /// 请注意, 应用程序的浮动窗口(如检查器窗口)可能会保持在执行提升操作的窗口之上.
    case raise = "AXRaise"
    /// 显示备用或隐藏的 UI. 通常用于触发与鼠标悬停时发生的相同变化.
    case showAlternateUI = "AXShowAlternateUI"
    /// 显示默认 UI. 通常用于触发与鼠标悬停结束时发生的相同变化.
    case showDefaultUI = "AXShowDefaultUI"
    /// 模拟在该可访问性对象所代表的元素上打开上下文菜单.
    /// 此操作也可用于模拟与元素预先关联的菜单的显示, 例如当用户慢慢点击 Safari 的返回按钮时显示的菜单.
    case showMenu = "AXShowMenu"
    
    // MARK: 未定义但是存在的
    case scrollToVisible = "AXScrollToVisible"
    case scrollLeftByPage = "AXScrollLeftByPage"
    case scrollRightByPage = "AXScrollRightByPage"
    case scrollUpByPage = "AXScrollUpByPage"
    case scrollDownByPage = "AXScrollDownByPage"
    case zoomWindow = "AXZoomWindow"
    
    // MARK: 未知
    case unknown = "AXUnknown"
}

extension AccessibilityElement {
    /// 模拟单击操作, 例如点击按钮.
    func perform(_ action: AccessibilityElementAction) -> Bool {
        let result = AXUIElementPerformAction(original, action.rawValue as CFString)
        return result == .success
    }

    func description(_ action: AccessibilityElementAction) -> String? {
        var description: CFString?
        let error = AXUIElementCopyActionDescription(original, action.rawValue as CFString, &description)

        return description as String?
    }

    func actions() -> [AccessibilityElementAction] {
        var actions: CFArray?
        let error = AXUIElementCopyActionNames(original, &actions)
        return (actions as? [String] ?? []).compactMap {
            if let t = AccessibilityElementAction(rawValue: $0) {
                return t
            } else {
                print("未知操作: \($0)")
                return .unknown
            }
        }
    }
}
