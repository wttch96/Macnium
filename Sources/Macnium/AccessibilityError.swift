//
//  AccessibilityError.swift
//  Macnium
//
//  Created by Wttch on 2024/11/10.
//
import AppKit

/// 辅助功能错误声明
enum AccessibilityError: Error {
    /// 原始的 AXError 错误
    case error(AXError)
    /// 类型转换错误
    case typeError(String)
}
