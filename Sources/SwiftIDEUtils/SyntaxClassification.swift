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

@_spi(RawSyntax) import SwiftSyntax

public enum SyntaxClassification {
  /// An attribute starting with an `@`.
  case attribute
  /// A block comment starting with `/**` and ending with `*/.
  case blockComment
  /// A build configuration directive like `#if`, `#elseif`, `#else`.
  case buildConfigId
  /// A doc block comment starting with `/**` and ending with `*/.
  case docBlockComment
  /// A doc line comment starting with `///`.
  case docLineComment
  /// An identifier starting with `$` like `$0`.
  case dollarIdentifier
  /// An editor placeholder of the form `<#content#>`
  case editorPlaceholder
  /// A floating point literal.
  case floatingLiteral
  /// A generic identifier.
  case identifier
  /// An integer literal.
  case integerLiteral
  /// A Swift keyword, including contextual keywords.
  case keyword
  /// A line comment starting with `//`.
  case lineComment
  /// The token should not receive syntax coloring.
  case none
  /// An image, color, etc. literal.
  case objectLiteral
  /// An identifier referring to an operator.
  case operatorIdentifier
  /// A `#` token like `#warning`.
  case poundDirective
  /// A regex literal, including multiline regex literals.
  case regexLiteral
  /// The opening and closing parenthesis of string interpolation.
  case stringInterpolationAnchor
  /// A string literal including multiline string literals.
  case stringLiteral
  /// An identifier referring to a type.
  case typeIdentifier
}

extension SyntaxClassification {
  /// Checks if a node has a classification attached via its syntax definition.
  /// - Parameters:
  ///   - parentKind: The parent node syntax kind.
  ///   - indexInParent: The index of the node in its parent.
  ///   - childKind: The node syntax kind.
  /// - Returns: A pair of classification and whether it is "forced", or nil if
  ///   no classification is attached.
  internal static func classify(_ keyPath: AnyKeyPath) -> (SyntaxClassification, Bool)? {
    switch keyPath {
    case \AttributeSyntax.attributeName:
      return (.attribute, false)
    case \PlatformVersionItemSyntax.availabilityVersionRestriction:
      return (.keyword, false)
    case \AvailabilityVersionRestrictionSyntax.platform:
      return (.keyword, false)
    case \DeclModifierSyntax.name:
      return (.attribute, false)
    case \ExpressionSegmentSyntax.leftParen:
      return (.stringInterpolationAnchor, true)
    case \ExpressionSegmentSyntax.rightParen:
      return (.stringInterpolationAnchor, true)
    case \IfConfigClauseSyntax.poundKeyword:
      return (.buildConfigId, false)
    case \IfConfigClauseSyntax.condition:
      return (.buildConfigId, false)
    case \IfConfigDeclSyntax.poundEndif:
      return (.buildConfigId, false)
    case \MemberTypeIdentifierSyntax.name:
      return (.typeIdentifier, false)
    case \OperatorDeclSyntax.name:
      return (.operatorIdentifier, false)
    case \PrecedenceGroupAssociativitySyntax.associativityLabel:
      return (.keyword, false)
    case \PrecedenceGroupRelationSyntax.higherThanOrLowerThanLabel:
      return (.keyword, false)
    case \SimpleTypeIdentifierSyntax.name:
      return (.typeIdentifier, false)
    default:
      return nil
    }
  }
}

extension RawTokenKind {
  internal var classification: SyntaxClassification {
    switch self {
    case .arrow:
      return .none
    case .atSign:
      return .attribute
    case .backslash:
      return .none
    case .backtick:
      return .none
    case .binaryOperator:
      return .operatorIdentifier
    case .colon:
      return .none
    case .comma:
      return .none
    case .dollarIdentifier:
      return .dollarIdentifier
    case .ellipsis:
      return .none
    case .endOfFile:
      return .none
    case .equal:
      return .none
    case .exclamationMark:
      return .none
    case .floatingLiteral:
      return .floatingLiteral
    case .identifier:
      return .identifier
    case .infixQuestionMark:
      return .none
    case .integerLiteral:
      return .integerLiteral
    case .keyword:
      return .keyword
    case .leftAngle:
      return .none
    case .leftBrace:
      return .none
    case .leftParen:
      return .none
    case .leftSquare:
      return .none
    case .multilineStringQuote:
      return .stringLiteral
    case .period:
      return .none
    case .postfixOperator:
      return .operatorIdentifier
    case .postfixQuestionMark:
      return .none
    case .pound:
      return .none
    case .poundAvailable:
      return .none
    case .poundElse:
      return .poundDirective
    case .poundElseif:
      return .poundDirective
    case .poundEndif:
      return .poundDirective
    case .poundIf:
      return .poundDirective
    case .poundSourceLocation:
      return .poundDirective
    case .poundUnavailable:
      return .none
    case .prefixAmpersand:
      return .none
    case .prefixOperator:
      return .operatorIdentifier
    case .rawStringPoundDelimiter:
      return .none
    case .regexLiteralPattern:
      return .regexLiteral
    case .regexPoundDelimiter:
      return .regexLiteral
    case .regexSlash:
      return .regexLiteral
    case .rightAngle:
      return .none
    case .rightBrace:
      return .none
    case .rightParen:
      return .none
    case .rightSquare:
      return .none
    case .semicolon:
      return .none
    case .singleQuote:
      return .stringLiteral
    case .stringQuote:
      return .stringLiteral
    case .stringSegment:
      return .stringLiteral
    case .unknown:
      return .none
    case .wildcard:
      return .none
    }
  }
}
