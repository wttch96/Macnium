//
//  AccessibilityElementAttribute.swift
//  Macnium
//
//  Created by Wttch on 2024/11/10.
//
import AppKit

/// 辅助功能属性键, 对原始键进行了包装, 使其可以指定键对应值的类型.
/// 不使用 enum 是因为 enum 无法指定关联值的类型(如果使用 `Any`则和手动转换无异).
struct AccessibilityElementAttributeKey<O, T> {
    let key: String
    let originalType: O.Type
    let convertedType: T.Type

    let convertFunc: (O) -> T

    init(key: String, convertFunc: @escaping (O) -> T) {
        self.key = key
        self.originalType = O.self
        self.convertedType = T.self
        self.convertFunc = convertFunc
    }

    init(key: String) where O == T {
        self.init(key: key) { $0 }
    }
}

// MARK: 原始属性

private typealias OriginalAttribute<O> = AccessibilityElementAttributeKey<O, O>

extension OriginalAttribute<[Any]> {
    static var allowedValues: Self {
        .init(key: kAXAllowedValuesAttribute)
    }
}

extension OriginalAttribute<[AXUIElement]> {
    /// 一个包含辅助功能对象的数组, 表示此应用程序的窗口.
    /// 建议所有应用程序级别的辅助功能对象使用此属性.
    static var windows: Self {
        .init(key: kAXWindowsAttribute)
    }

    static var children: Self {
        .init(key: kAXChildrenAttribute)
    }
}

extension OriginalAttribute<AXUIElement> {
    static var parent: Self {
        .init(key: kAXParentAttribute)
    }
}

// MARK: 原始字符串属性

extension OriginalAttribute<String> {
    static var description: Self {
        .init(key: kAXDescriptionAttribute)
    }

    static var title: Self {
        .init(key: kAXTitleAttribute)
    }
}

// MARK: 可转换字符串属性

private typealias ConvertibleStringAttribute<T> = AccessibilityElementAttributeKey<String, T>

private typealias ConvertibleStringAttributeWithRawValue<T: RawRepresentable> = AccessibilityElementAttributeKey<String, T>

extension ConvertibleStringAttributeWithRawValue<AccessibilityRole> {
    /// 角色或类型, 表示此辅助功能对象的类型(例如，AXButton).
    /// 该字符串仅用于识别目的, 无需本地化. 所有辅助功能对象必须包含此属性.
    /// 参见: https://developer.apple.com/documentation/applicationservices/kaxroleattribute
    static var role: Self {
        .init(key: kAXRoleAttribute, convertFunc: {
            if let role: T = .init(rawValue: $0) {
                return role
            }
            print("未知辅助功能对象类型: \($0)")
            return .unknown
        })
    }
}

extension ConvertibleStringAttributeWithRawValue<AccessibilitySubrole> {
    /// 参见: https://developer.apple.com/documentation/applicationservices/kaxsubroleattribute
    static var subrole: Self {
        .init(key: kAXSubroleAttribute, convertFunc: { .init(rawValue: $0)! })
    }
}
