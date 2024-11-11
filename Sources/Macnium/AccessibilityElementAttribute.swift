//
//  AccessibilityElementAttribute.swift
//  Macnium
//
//  Created by Wttch on 2024/11/10.
//
import AppKit

/// 辅助功能属性键, 对原始键进行了包装, 使其可以指定键对应值的类型.
/// 不使用 enum 是因为 enum 无法指定关联值的类型(如果使用 `Any`则和手动转换无异).
struct AccessibilityElementAttributeKey<T> {
    let key: String
    let type: T.Type

    init(key: String, type: T.Type) {
        self.key = key
        self.type = type
    }
}

extension AccessibilityElementAttributeKey {
    static var allowedValues: AccessibilityElementAttributeKey<[Any]> {
        .init(key: kAXAllowedValuesAttribute, type: [Any].self)
    }
}

extension AccessibilityElementAttributeKey where T == String {
    /// 角色或类型, 表示此辅助功能对象的类型(例如，AXButton).
    /// 该字符串仅用于识别目的, 无需本地化. 所有辅助功能对象必须包含此属性.
    /// 参见: https://developer.apple.com/documentation/applicationservices/kaxroleattribute
    static var role: Self {
        .init(key: kAXRoleAttribute, type: String.self)
    }

    static var description: Self {
        .init(key: kAXDescriptionAttribute, type: String.self)
    }

    static var title: Self {
        .init(key: kAXTitleAttribute, type: String.self)
    }
}

extension AccessibilityElementAttributeKey where T == [AXUIElement] {
    /// 一个包含辅助功能对象的数组, 表示此应用程序的窗口.
    /// 建议所有应用程序级别的辅助功能对象使用此属性.
    static var windows: Self {
        .init(key: kAXWindowsAttribute, type: [AXUIElement].self)
    }

    static var children: Self {
        .init(key: kAXChildrenAttribute, type: [AXUIElement].self)
    }
}

extension AccessibilityElementAttributeKey where T == AXUIElement {
    static var parent: Self {
        .init(key: kAXParentAttribute, type: AXUIElement.self)
    }
}
