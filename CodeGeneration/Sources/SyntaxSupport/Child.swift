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

import SwiftSyntax

/// The kind of token a node can contain. Either a token of a specific kind or a
/// keyword with the given text.
public enum TokenChoice: Equatable {
  case keyword(text: String)
  case token(tokenKind: String)

  public var isKeyword: Bool {
    switch self {
    case .keyword: return true
    case .token: return false
    }
  }
}

public enum ChildKind {
  /// The child always contains a node of the given `kind`.
  case node(kind: SyntaxNodeKind)
  /// The child always contains a node that matches one of the `choices`.
  case nodeChoices(choices: [Child])
  /// The child is a collection of `kind`.
  case collection(kind: SyntaxNodeKind, collectionElementName: String, deprecatedCollectionElementName: String? = nil)
  /// The child is a token that matches one of the given `choices`.
  /// If `requiresLeadingSpace` or `requiresTrailingSpace` is not `nil`, it
  /// overrides the default leading/trailing space behavior of the token.
  case token(choices: [TokenChoice], requiresLeadingSpace: Bool? = nil, requiresTrailingSpace: Bool? = nil)

  public var isNodeChoices: Bool {
    if case .nodeChoices = self {
      return true
    } else {
      return false
    }
  }

  public var isNodeChoicesEmpty: Bool {
    if case .nodeChoices(let nodeChoices) = self {
      return nodeChoices.isEmpty
    } else {
      return true
    }
  }
}

/// A child of a node, that may be declared optional or a token with a
/// restricted subset of acceptable kinds or texts.
public class Child {
  /// The name of the child.
  ///
  /// The first character of the name is always uppercase.
  public let name: String

  /// If the child has been renamed, its old, now deprecated, name.
  ///
  /// This is used to generate deprecated compatibility layers.
  public let deprecatedName: String?

  /// The kind of the child (node, token, collection, ...)
  public let kind: ChildKind

  /// Whether this child is optional and can be `nil`.
  public let isOptional: Bool

  /// A name of this child that can be shown in diagnostics.
  ///
  /// This is used to e.g. describe the child if all of its tokens are missing in the source file.
  public let nameForDiagnostics: String?

  /// A doc comment describing the child.
  public let documentation: SwiftSyntax.Trivia

  /// The first line of the child's documentation
  public let documentationAbstract: String

  public var syntaxNodeKind: SyntaxNodeKind {
    switch kind {
    case .node(kind: let kind):
      return kind
    case .nodeChoices:
      return .syntax
    case .collection(kind: let kind, _, _):
      return kind
    case .token:
      return .token
    }
  }

  /// A name of this child that's suitable to be used for variable or enum case names.
  public var varOrCaseName: TokenSyntax {
    return .identifier(lowercaseFirstWord(name: name))
  }

  /// The deprecated name of this child that's suitable to be used for variable or enum case names.
  public var deprecatedVarName: TokenSyntax? {
    guard let deprecatedName = deprecatedName else {
      return nil
    }
    return .identifier(lowercaseFirstWord(name: deprecatedName))
  }

  /// If the child ends with "token" in the kind, it's considered a token node.
  /// Grab the existing reference to that token from the global list.
  public var tokenKind: String? {
    switch kind {
    case .token(choices: let choices, requiresLeadingSpace: _, requiresTrailingSpace: _):
      if choices.count == 1 {
        switch choices.first! {
        case .keyword: return "KeywordToken"
        case .token(tokenKind: let tokenKind): return tokenKind
        }
      } else {
        if choices.allSatisfy({ $0.isKeyword }) {
          return "KeywordToken"
        } else {
          return "Token"
        }
      }
    default:
      return nil
    }
  }

  /// Returns `true` if this child has a token kind.
  public var isToken: Bool {
    return tokenKind != nil
  }

  public var token: TokenSpec? {
    guard let tokenKind = tokenKind else { return nil }
    return SYNTAX_TOKEN_MAP[tokenKind]
  }

  /// Whether this child has syntax kind `UnexpectedNodes`.
  public var isUnexpectedNodes: Bool {
    switch kind {
    case .collection(kind: .unexpectedNodes, _, _):
      return true
    default:
      return false
    }
  }

  /// Returns `true` if this child's type is one of the base syntax kinds and
  /// it has no node choices.
  public var hasBaseType: Bool {
    switch kind {
    case .nodeChoices(let choices):
      return choices.isEmpty
    case .node(let kind):
      return kind.isBase
    case .collection(let kind, _, _):
      return kind.isBase
    case .token:
      return false
    }
  }

  /// If a classification is passed, it specifies the color identifiers in
  /// that subtree should inherit for syntax coloring. Must be a member of
  /// ``SyntaxClassification``.
  /// If `forceClassification` is also set to true, all child nodes (not only
  /// identifiers) inherit the syntax classification.
  init(
    name: String,
    deprecatedName: String? = nil,
    kind: ChildKind,
    nameForDiagnostics: String? = nil,
    documentation: String? = nil,
    isOptional: Bool = false
  ) {
    if let firstCharInName = name.first {
      precondition(firstCharInName.isUppercase == true, "The first letter of a child’s name should be uppercase")
    }
    self.name = name
    self.deprecatedName = deprecatedName
    self.kind = kind
    self.nameForDiagnostics = nameForDiagnostics
    self.documentation = docCommentTrivia(from: documentation)
    self.documentationAbstract = String(documentation?.split(whereSeparator: \.isNewline).first ?? "")
    self.isOptional = isOptional
  }
}
