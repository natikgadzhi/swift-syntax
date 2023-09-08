//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

// This file provides compatiblity aliases to keep dependents of SwiftSyntax building.
// All users of the declarations in this file should transition away from them ASAP.

public extension SyntaxClassification {
  /// A `#` keyword like `#warning`.
  @available(*, deprecated, renamed: "ifConfigDirective")
  static var poundDirective: SyntaxClassification {
    .ifConfigDirective
  }

  @available(*, deprecated, renamed: "ifConfigDirective")
  static var buildConfigId: SyntaxClassification {
    .ifConfigDirective
  }

  @available(*, deprecated, message: "String interpolation anchors are now classified as .none")
  static var stringInterpolationAnchor: SyntaxClassification {
    .none
  }

  @available(*, deprecated, renamed: "type")
  static var typeIdentifier: SyntaxClassification {
    .type
  }

  @available(*, deprecated, renamed: "operator")
  static var operatorIdentifier: SyntaxClassification {
    .operator
  }

  @available(*, deprecated, renamed: "floatLiteral")
  static var floatingLiteral: SyntaxClassification {
    .floatLiteral
  }
}

//==========================================================================//
// IMPORTANT: If you are tempted to add a compatiblity layer code here      //
// please insert it in alphabetical order above                             //
//==========================================================================//
