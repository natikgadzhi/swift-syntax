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

public let DECL_NODES: [Node] = [
  Node(
    kind: .importPathComponent,
    base: .syntax,
    nameForDiagnostics: nil,
    children: [
      Child(
        name: "Name",
        kind: .token(choices: [
          .token(tokenKind: "IdentifierToken"),
          .token(tokenKind: "BinaryOperatorToken"),
          .token(tokenKind: "PrefixOperatorToken"),
          .token(tokenKind: "PostfixOperatorToken"),
        ]),
        nameForDiagnostics: "name"
      ),
      Child(
        name: "TrailingPeriod",
        deprecatedName: "TrailingDot",
        kind: .token(choices: [.token(tokenKind: "PeriodToken")]),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .importPathComponentList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.importPathComponent]
  ),

  Node(
    kind: .accessorBlock,
    base: .syntax,
    nameForDiagnostics: nil,
    parserFunction: "parseAccessorBlock",
    traits: [
      "Braced"
    ],
    children: [
      Child(
        name: "LeftBrace",
        kind: .token(choices: [.token(tokenKind: "LeftBraceToken")])
      ),
      Child(
        name: "Accessors",
        kind: .nodeChoices(choices: [
          Child(
            name: "Accessors",
            kind: .collection(kind: .accessorDeclList, collectionElementName: "Accessor")
          ),
          Child(
            name: "Getter",
            kind: .node(kind: .codeBlockItemList)
          ),
        ])
      ),
      Child(
        name: "RightBrace",
        kind: .token(choices: [.token(tokenKind: "RightBraceToken")])
      ),
    ]
  ),

  Node(
    kind: .accessorDecl,
    base: .decl,
    nameForDiagnostics: "accessor",
    parserFunction: "parseAccessorDecl",
    traits: ["WithAttributes"],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifier",
        kind: .node(kind: .declModifier),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "AccessorSpecifier",
        deprecatedName: "AccessorKind",
        kind: .token(choices: [
          .keyword(text: "get"),
          .keyword(text: "set"),
          .keyword(text: "didSet"),
          .keyword(text: "willSet"),
          .keyword(text: "unsafeAddress"),
          .keyword(text: "addressWithOwner"),
          .keyword(text: "addressWithNativeOwner"),
          .keyword(text: "unsafeMutableAddress"),
          .keyword(text: "mutableAddressWithOwner"),
          .keyword(text: "mutableAddressWithNativeOwner"),
          .keyword(text: "_read"),
          .keyword(text: "_modify"),
          .keyword(text: "init"),
        ])
      ),
      Child(
        name: "Parameters",
        deprecatedName: "Parameter",
        kind: .node(kind: .accessorParameters),
        nameForDiagnostics: "parameter",
        isOptional: true
      ),
      Child(
        name: "EffectSpecifiers",
        kind: .node(kind: .accessorEffectSpecifiers),
        isOptional: true
      ),
      Child(
        name: "Body",
        kind: .node(kind: .codeBlock),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .accessorDeclList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.accessorDecl]
  ),

  // (value)
  Node(
    kind: .accessorParameters,
    base: .syntax,
    nameForDiagnostics: nil,
    traits: [
      "Parenthesized"
    ],
    children: [
      Child(
        name: "LeftParen",
        kind: .token(choices: [.token(tokenKind: "LeftParenToken")])
      ),
      Child(
        name: "Name",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        nameForDiagnostics: "name"
      ),
      Child(
        name: "RightParen",
        kind: .token(choices: [.token(tokenKind: "RightParenToken")])
      ),
    ]
  ),

  // actor-declaration -> attributes? access-level-modifier?
  //                      'actor' actor-name
  //                      generic-parameter-clause?
  //                      type-inheritance-clause?
  //                      generic-where-clause?
  //                     '{' actor-members '}'
  // actor-name -> identifier
  Node(
    kind: .actorDecl,
    base: .decl,
    nameForDiagnostics: "actor",
    traits: [
      "DeclGroup",
      "NamedDecl",
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "ActorKeyword",
        kind: .token(choices: [.keyword(text: "actor")])
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")])
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The parameter clause that defines the generic parameters.",
        isOptional: true
      ),
      Child(
        name: "InheritanceClause",
        kind: .node(kind: .inheritanceClause),
        nameForDiagnostics: "inheritance clause",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
        isOptional: true
      ),
      Child(
        name: "MemberBlock",
        kind: .node(kind: .memberBlock)
      ),
    ]
  ),

  // associatedtype-declaration -> attributes? access-level-modifier?
  //                                 'associatedtype' associatedtype-name
  //                                 inheritance-clause? type-assignment?
  //                                 generic-where-clause?
  // associatedtype-name -> identifier
  Node(
    kind: .associatedTypeDecl,
    base: .decl,
    nameForDiagnostics: "associatedtype declaration",
    documentation: """
      An associated type declaration like the following.

      ```swift
      associatedtype Item
      ```

      An associated type declaration may contain a type initializer clause which represents a default type assignment for the associated type.

      ```swift
      associatedtype Item = Int
      ```

      An associated type declaration may be declared with an inheritance clause which specifies the required conformances.

      ```swift
      associatedtype Iterator: IteratorProtocol
      ```

      A generic where clause may be present, here is an example which shows an associated type containing an inheritance clauses and a generic where clause.

      ```swift
      associatedtype Iterator: IteratorProtocol where Iterator.Element == Item
      ```
      """,
    traits: [
      "NamedDecl",
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "Attributes attached to the associated type declaration.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "Modifiers attached to the associated type declaration.",
        isOptional: true
      ),
      Child(
        name: "AssociatedtypeKeyword",
        kind: .token(choices: [.keyword(text: "associatedtype")]),
        documentation: "The `associatedtype` keyword for this declaration."
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: "The name of this associated type."
      ),
      Child(
        name: "InheritanceClause",
        kind: .node(kind: .inheritanceClause),
        nameForDiagnostics: "inheritance clause",
        documentation: "The inheritance clause describing conformances for this associated type declaration.",
        isOptional: true
      ),
      Child(
        name: "Initializer",
        kind: .node(kind: .typeInitializerClause),
        documentation: "The type initializer clause for this associated type declaration which represents a default type assignment for the associated type.",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "The `where` clause that applies to the generic parameters of this associated type declaration.",
        isOptional: true
      ),
    ]
  ),

  // class-declaration -> attributes? access-level-modifier?
  //                      'class' class-name
  //                      generic-parameter-clause?
  //                      type-inheritance-clause?
  //                      generic-where-clause?
  //                     '{' class-members '}'
  // class-name -> identifier
  Node(
    kind: .classDecl,
    base: .decl,
    nameForDiagnostics: "class",
    documentation: """
      A class declaration like the following.

      ```swift
      class SomeClass {
        let someMember: String

        init(someMember: String) {
          self.someMember = someMember
        }

        func foo() {
          print(someMember)
        }

        static func bar() -> Int {
          return 1
        }
      }
      ```

      A class declaration may be declared without any members.
      """,
    traits: [
      "DeclGroup",
      "NamedDecl",
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "Attributes attached to the class declaration, such as an `@available` attribute.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "Modifiers attached to the class declaration, such as `public`.",
        isOptional: true
      ),
      Child(
        name: "ClassKeyword",
        kind: .token(choices: [.keyword(text: "class")]),
        documentation: "The `class` keyword for this declaration."
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: "The name of the class."
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The generic parameters, if any, of the class declaration.",
        isOptional: true
      ),
      Child(
        name: "InheritanceClause",
        kind: .node(kind: .inheritanceClause),
        nameForDiagnostics: "inheritance clause",
        documentation: "The inheritance clause describing one or more conformances for this class declaration.",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "The `where` clause that applies to the generic parameters of this class declaration.",
        isOptional: true
      ),
      Child(
        name: "MemberBlock",
        kind: .node(kind: .memberBlock),
        documentation:
          "The members of the class declaration. As class extension declarations may declare additional members, the contents of this member block isn't guaranteed to be a complete list of members for this type."
      ),
    ]
  ),

  Node(
    kind: .declModifierDetail,
    base: .syntax,
    nameForDiagnostics: nil,
    traits: [
      "Parenthesized"
    ],
    children: [
      Child(
        name: "LeftParen",
        kind: .token(choices: [.token(tokenKind: "LeftParenToken")])
      ),
      Child(
        name: "Detail",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")])
      ),
      Child(
        name: "RightParen",
        kind: .token(choices: [.token(tokenKind: "RightParenToken")])
      ),
    ]
  ),

  Node(
    kind: .declModifier,
    base: .syntax,
    nameForDiagnostics: "modifier",
    children: [
      Child(
        name: "Name",
        kind: .token(choices: [
          .keyword(text: "__consuming"),
          .keyword(text: "__setter_access"),
          .keyword(text: "_const"),
          .keyword(text: "_local"),
          .keyword(text: "actor"),
          .keyword(text: "async"),
          .keyword(text: "borrowing"),
          .keyword(text: "class"),
          .keyword(text: "consuming"),
          .keyword(text: "convenience"),
          .keyword(text: "distributed"),
          .keyword(text: "dynamic"),
          .keyword(text: "fileprivate"),
          .keyword(text: "final"),
          .keyword(text: "indirect"),
          .keyword(text: "infix"),
          .keyword(text: "internal"),
          .keyword(text: "isolated"),
          .keyword(text: "lazy"),
          .keyword(text: "mutating"),
          .keyword(text: "nonisolated"),
          .keyword(text: "nonmutating"),
          .keyword(text: "open"),
          .keyword(text: "optional"),
          .keyword(text: "override"),
          .keyword(text: "package"),
          .keyword(text: "postfix"),
          .keyword(text: "prefix"),
          .keyword(text: "private"),
          .keyword(text: "public"),
          .keyword(text: "reasync"),
          .keyword(text: "required"),
          .keyword(text: "static"),
          .keyword(text: "unowned"),
          .keyword(text: "weak"),
        ])
      ),
      Child(
        name: "Detail",
        kind: .node(kind: .declModifierDetail),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .deinitializerDecl,
    base: .decl,
    nameForDiagnostics: "deinitializer",
    documentation: """
      A deinitializer declaration like the following.

      ```swift
      deinit {
      }
      ```
      """,
    traits: [
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "Attributes that are attached to the deinitializer.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "Modifiers that are attached to the deinitializer.",
        isOptional: true
      ),
      Child(
        name: "DeinitKeyword",
        kind: .token(choices: [.keyword(text: "deinit")]),
        documentation: "The deinit keyword."
      ),
      Child(
        name: "EffectSpecifiers",
        kind: .node(kind: .deinitializerEffectSpecifiers),
        isOptional: true
      ),
      Child(
        name: "Body",
        kind: .node(kind: .codeBlock),
        documentation: "The deinitializer's body.",
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .designatedType,
    base: .syntax,
    nameForDiagnostics: nil,
    children: [
      Child(
        name: "LeadingComma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")])
      ),
      Child(
        name: "Name",
        kind: .node(kind: .token)
      ),
    ]
  ),

  // designated-type-list -> (',' identifier)*
  Node(
    kind: .designatedTypeList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.designatedType]
  ),

  // <#content#>
  Node(
    kind: .editorPlaceholderDecl,
    base: .decl,
    nameForDiagnostics: "editor placeholder",
    documentation: """
      An editor placeholder, e.g. `<#declaration#>` that is used in a position that expects a declaration.
      """,
    traits: [
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        documentation: "If there were attributes before the editor placeholder, the ``EditorPlaceholderDeclSyntax`` will contain these.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        documentation: "If there were modifiers before the editor placeholder, the `EditorPlaceholderDecl` will contain these.",
        isOptional: true
      ),
      Child(
        name: "Placeholder",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: """
          The actual editor placeholder that starts with `<#` and ends with `#>`.
          """
      ),
    ]
  ),

  Node(
    kind: .enumCaseParameterClause,
    base: .syntax,
    nameForDiagnostics: "parameter clause",
    traits: [
      "Parenthesized"
    ],
    children: [
      Child(
        name: "LeftParen",
        kind: .token(choices: [.token(tokenKind: "LeftParenToken")]),
        documentation: "The '(' to open the parameter clause."
      ),
      Child(
        name: "Parameters",
        deprecatedName: "ParameterList",
        kind: .collection(kind: .enumCaseParameterList, collectionElementName: "Parameter"),
        nameForDiagnostics: "parameters",
        documentation: "The actual parameters."
      ),
      Child(
        name: "RightParen",
        kind: .token(choices: [.token(tokenKind: "RightParenToken")]),
        documentation: "The ')' to close the parameter clause."
      ),
    ]
  ),

  Node(
    kind: .enumCaseParameterList,
    base: .syntaxCollection,
    nameForDiagnostics: "parameter list",
    elementChoices: [.enumCaseParameter]
  ),

  Node(
    kind: .enumCaseParameter,
    base: .syntax,
    nameForDiagnostics: "parameter",
    parserFunction: "parseEnumCaseParameter",
    traits: ["WithTrailingComma", "WithModifiers"],
    children: [
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "FirstName",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken"), .token(tokenKind: "WildcardToken")]),
        isOptional: true
      ),
      Child(
        name: "SecondName",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken"), .token(tokenKind: "WildcardToken")]),
        isOptional: true
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")]),
        documentation: "If the parameter has a label, the colon separating the label from the type.",
        isOptional: true
      ),
      Child(
        name: "Type",
        kind: .node(kind: .type),
        nameForDiagnostics: "type",
        documentation: "The parameter's type."
      ),
      Child(
        name: "DefaultValue",
        deprecatedName: "DefaultArgument",
        kind: .node(kind: .initializerClause),
        nameForDiagnostics: "default value",
        documentation: "If the parameter has a default value, the initializer clause describing the default value.",
        isOptional: true
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")]),
        documentation: "If the parameter is followed by another parameter, the comma separating them.",
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .enumCaseDecl,
    base: .decl,
    nameForDiagnostics: "enum case",
    documentation: "A `case` declaration of a Swift `enum`. It can have 1 or more `EnumCaseElement`s inside, each declaring a different case of the enum.",
    traits: [
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "The attributes applied to the case declaration.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "The declaration modifiers applied to the case declaration.",
        isOptional: true
      ),
      Child(
        name: "CaseKeyword",
        kind: .token(choices: [.keyword(text: "case")]),
        documentation: "The `case` keyword for this case."
      ),
      Child(
        name: "Elements",
        kind: .collection(kind: .enumCaseElementList, collectionElementName: "Element"),
        nameForDiagnostics: "elements",
        documentation: "The elements this case declares."
      ),
    ]
  ),

  Node(
    kind: .enumCaseElementList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    documentation: "A collection of 0 or more `EnumCaseElement`s.",
    elementChoices: [.enumCaseElement]
  ),

  Node(
    kind: .enumCaseElement,
    base: .syntax,
    nameForDiagnostics: nil,
    documentation: "An element of an enum case, containing the name of the case and, optionally, either associated values or an assignment to a raw value.",
    traits: [
      "WithTrailingComma"
    ],
    children: [
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: "The name of this case."
      ),
      Child(
        name: "ParameterClause",
        deprecatedName: "AssociatedValue",
        kind: .node(kind: .enumCaseParameterClause),
        nameForDiagnostics: "associated values",
        documentation: "The set of associated values of the case.",
        isOptional: true
      ),
      Child(
        name: "RawValue",
        kind: .node(kind: .initializerClause),
        documentation: "The raw value of this enum element, if present.",
        isOptional: true
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")]),
        documentation: "The trailing comma of this element, if the case has multiple elements.",
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .enumDecl,
    base: .decl,
    nameForDiagnostics: "enum",
    documentation: "A Swift `enum` declaration.",
    traits: [
      "DeclGroup",
      "NamedDecl",
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "The attributes applied to the enum declaration.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "The declaration modifiers applied to the enum declaration.",
        isOptional: true
      ),
      Child(
        name: "EnumKeyword",
        kind: .token(choices: [.keyword(text: "enum")]),
        documentation: "The `enum` keyword for this declaration."
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: "Declares the name of this enum. If the name matches a reserved keyword use backticks to escape it."
      ),
      Child(
        name: "GenericParameterClause",
        deprecatedName: "GenericParameters",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The generic parameters, if any, for this enum declaration.",
        isOptional: true
      ),
      Child(
        name: "InheritanceClause",
        kind: .node(kind: .inheritanceClause),
        nameForDiagnostics: "inheritance clause",
        documentation: "The inheritance clause describing conformances or raw values for this enum declaration.",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "The `where` clause that applies to the generic parameters of this enum declaration.",
        isOptional: true
      ),
      Child(
        name: "MemberBlock",
        kind: .node(kind: .memberBlock),
        documentation:
          "The cases and other members associated with this enum declaration. Because enum extension declarations may declare additional members the contents of this member block isn't guaranteed to be a complete list of members for this type."
      ),
    ]
  ),

  // extension-declaration -> attributes? access-level-modifier?
  //                            'extension' extended-type
  //                              type-inheritance-clause?
  //                            generic-where-clause?
  //                            '{' extension-members '}'
  // extension-name -> identifier
  Node(
    kind: .extensionDecl,
    base: .decl,
    nameForDiagnostics: "extension",
    traits: [
      "DeclGroup",
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "ExtensionKeyword",
        kind: .token(choices: [.keyword(text: "extension")])
      ),
      Child(
        name: "ExtendedType",
        kind: .node(kind: .type)
      ),
      Child(
        name: "InheritanceClause",
        kind: .node(kind: .inheritanceClause),
        nameForDiagnostics: "inheritance clause",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
        isOptional: true
      ),
      Child(
        name: "MemberBlock",
        kind: .node(kind: .memberBlock)
      ),
    ]
  ),

  Node(
    kind: .functionDecl,
    base: .decl,
    nameForDiagnostics: "function",
    traits: [
      "NamedDecl",
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "FuncKeyword",
        kind: .token(choices: [.keyword(text: "func")])
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [
          .token(tokenKind: "IdentifierToken"),
          .token(tokenKind: "BinaryOperatorToken"),
          .token(tokenKind: "PrefixOperatorToken"),
          .token(tokenKind: "PostfixOperatorToken"),
        ])
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The parameter clause that defines the generic parameters.",
        isOptional: true
      ),
      Child(
        name: "Signature",
        kind: .node(kind: .functionSignature),
        nameForDiagnostics: "function signature"
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
        isOptional: true
      ),
      Child(
        name: "Body",
        kind: .node(kind: .codeBlock),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .functionParameterList,
    base: .syntaxCollection,
    nameForDiagnostics: "parameter list",
    elementChoices: [.functionParameter]
  ),

  // parameter ->
  // external-parameter-name? local-parameter-name ':'
  //   type '...'? '='? expression? ','?
  Node(
    kind: .functionParameter,
    base: .syntax,
    nameForDiagnostics: "parameter",
    parserFunction: "parseFunctionParameter",
    traits: ["WithTrailingComma", "WithAttributes", "WithModifiers"],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "FirstName",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken"), .token(tokenKind: "WildcardToken")])
      ),
      // One of these two names needs be optional, we choose the second
      // name to avoid backtracking.
      Child(
        name: "SecondName",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken"), .token(tokenKind: "WildcardToken")], requiresLeadingSpace: true),
        nameForDiagnostics: "internal name",
        isOptional: true
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "Type",
        kind: .node(kind: .type),
        nameForDiagnostics: "type"
      ),
      Child(
        name: "Ellipsis",
        kind: .token(choices: [.token(tokenKind: "EllipsisToken")]),
        isOptional: true
      ),
      Child(
        name: "DefaultValue",
        deprecatedName: "DefaultArgument",
        kind: .node(kind: .initializerClause),
        nameForDiagnostics: "default value",
        isOptional: true
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")]),
        isOptional: true
      ),
    ]
  ),

  // function-signature ->
  //   '(' parameter-list? ')' function-effect-specifiers? return-clause?
  Node(
    kind: .functionSignature,
    base: .syntax,
    nameForDiagnostics: "function signature",
    children: [
      Child(
        name: "ParameterClause",
        deprecatedName: "Input",
        kind: .node(kind: .functionParameterClause)
      ),
      Child(
        name: "EffectSpecifiers",
        kind: .node(kind: .functionEffectSpecifiers),
        isOptional: true
      ),
      Child(
        name: "ReturnClause",
        deprecatedName: "Output",
        kind: .node(kind: .returnClause),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .ifConfigClauseList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.ifConfigClause]
  ),

  // if-config-clause ->
  //    ('#if' | '#elseif' | '#else') expr? (stmt-list | switch-case-list)
  Node(
    kind: .ifConfigClause,
    base: .syntax,
    nameForDiagnostics: "conditional compilation clause",
    children: [
      Child(
        name: "PoundKeyword",
        kind: .token(choices: [.token(tokenKind: "PoundIfToken"), .token(tokenKind: "PoundElseifToken"), .token(tokenKind: "PoundElseToken")])
      ),
      Child(
        name: "Condition",
        kind: .node(kind: .expr),
        nameForDiagnostics: "condition",
        isOptional: true
      ),
      Child(
        name: "Elements",
        kind: .nodeChoices(choices: [
          Child(
            name: "Statements",
            kind: .node(kind: .codeBlockItemList)
          ),
          Child(
            name: "SwitchCases",
            kind: .node(kind: .switchCaseList)
          ),
          Child(
            name: "Decls",
            kind: .node(kind: .memberBlockItemList)
          ),
          Child(
            name: "PostfixExpression",
            kind: .node(kind: .expr)
          ),
          Child(
            name: "Attributes",
            kind: .node(kind: .attributeList)
          ),
        ]),
        isOptional: true
      ),
    ]
  ),

  // if-config-decl -> '#if' expr stmt-list else-if-directive-clause-list
  //   else-clause? '#endif'
  Node(
    kind: .ifConfigDecl,
    base: .decl,
    nameForDiagnostics: "conditional compilation block",
    children: [
      Child(
        name: "Clauses",
        kind: .collection(kind: .ifConfigClauseList, collectionElementName: "Clause")
      ),
      Child(
        name: "PoundEndif",
        kind: .token(choices: [.token(tokenKind: "PoundEndifToken")])
      ),
    ]
  ),

  Node(
    kind: .importDecl,
    base: .decl,
    nameForDiagnostics: "import",
    documentation: """
      An import declaration like the following.

      ```swift
      import Foundation
      ```
      """,
    traits: [
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "Attributes attached to the import declaration, for example `@testable`.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "Modifiers attached to the import declaration. Currently, no modifiers are supported by Swift.",
        isOptional: true
      ),
      Child(
        name: "ImportKeyword",
        deprecatedName: "ImportTok",
        kind: .token(choices: [.keyword(text: "import")]),
        documentation: "The `import` keyword for this declaration."
      ),
      Child(
        name: "ImportKindSpecifier",
        deprecatedName: "ImportKind",
        kind: .token(choices: [
          .keyword(text: "typealias"),
          .keyword(text: "struct"),
          .keyword(text: "class"),
          .keyword(text: "enum"),
          .keyword(text: "protocol"),
          .keyword(text: "var"),
          .keyword(text: "let"),
          .keyword(text: "func"),
          .keyword(text: "inout"),
        ]),
        documentation: "The kind of declaration being imported. For example, a struct can be imported from a specific module.",
        isOptional: true
      ),
      Child(
        name: "Path",
        kind: .collection(kind: .importPathComponentList, collectionElementName: "PathComponent"),
        documentation: "The path to the module, submodule or symbol being imported."
      ),
    ]
  ),

  Node(
    kind: .inheritedTypeList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.inheritedType]
  ),

  Node(
    kind: .inheritedType,
    base: .syntax,
    nameForDiagnostics: "inherited type",
    traits: [
      "WithTrailingComma"
    ],
    children: [
      Child(
        name: "Type",
        deprecatedName: "TypeName",
        kind: .node(kind: .type)
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")]),
        isOptional: true
      ),
    ]
  ),

  // initializer -> '=' expr
  Node(
    kind: .initializerClause,
    base: .syntax,
    nameForDiagnostics: nil,
    children: [
      Child(
        name: "Equal",
        kind: .token(choices: [.token(tokenKind: "EqualToken")])
      ),
      Child(
        name: "Value",
        kind: .node(kind: .expr)
      ),
    ]
  ),

  Node(
    kind: .initializerDecl,
    base: .decl,
    nameForDiagnostics: "initializer",
    documentation: """
      An initializer declaration like the following.

      ```swift
      init(someParameter: Int) {
      }
      ```

      The body is optional because this node also represents initializer requirements inside protocols.
      """,
    traits: [
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "Attributes that are attached to the initializer.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "Modifiers attached to the initializer",
        isOptional: true
      ),
      Child(
        name: "InitKeyword",
        kind: .token(choices: [.keyword(text: "init")]),
        documentation: "The init keyword"
      ),
      Child(
        name: "OptionalMark",
        kind: .token(choices: [
          .token(tokenKind: "PostfixQuestionMarkToken"),
          .token(tokenKind: "InfixQuestionMarkToken"),
          .token(tokenKind: "ExclamationMarkToken"),
        ]),
        documentation: "If the initializer is failable, a question mark to indicate that.",
        isOptional: true
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "Generic parameters of the initializer.",
        isOptional: true
      ),
      Child(
        name: "Signature",
        kind: .node(kind: .functionSignature),
        nameForDiagnostics: "function signature",
        documentation: "The arguments of the initializer. While the function signature allows specifying a return clause, doing so is not semantically valid."
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "If the initializer had generic parameters, a where clause that can restrict those",
        isOptional: true
      ),
      Child(
        name: "Body",
        kind: .node(kind: .codeBlock),
        documentation: "The initializer’s body. Missing if the initializer is a requirement of a protocol declaration.",
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .macroDecl,
    base: .decl,
    nameForDiagnostics: "macro",
    traits: [
      "NamedDecl",
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "MacroKeyword",
        kind: .token(choices: [.keyword(text: "macro")])
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")])
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The parameter clause that defines the generic parameters.",
        isOptional: true
      ),
      Child(
        name: "Signature",
        kind: .node(kind: .functionSignature),
        nameForDiagnostics: "macro signature"
      ),
      Child(
        name: "Definition",
        kind: .node(kind: .initializerClause),
        nameForDiagnostics: "macro definition",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
        isOptional: true
      ),
    ]
  ),

  // e.g., "#embed("filename.txt")"
  Node(
    kind: .macroExpansionDecl,
    base: .decl,
    nameForDiagnostics: "macro expansion",
    traits: [
      "FreestandingMacroExpansion",
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "Pound",
        deprecatedName: "PoundToken",
        kind: .token(choices: [.token(tokenKind: "PoundToken")]),
        documentation: "The `#` sign."
      ),
      Child(
        name: "MacroName",
        deprecatedName: "Macro",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")])
      ),
      Child(
        name: "GenericArgumentClause",
        deprecatedName: "GenericArguments",
        kind: .node(kind: .genericArgumentClause),
        isOptional: true
      ),
      Child(
        name: "LeftParen",
        kind: .token(choices: [.token(tokenKind: "LeftParenToken")]),
        isOptional: true
      ),
      Child(
        name: "Arguments",
        deprecatedName: "ArgumentList",
        kind: .collection(kind: .labeledExprList, collectionElementName: "Argument")
      ),
      Child(
        name: "RightParen",
        kind: .token(choices: [.token(tokenKind: "RightParenToken")]),
        isOptional: true
      ),
      Child(
        name: "TrailingClosure",
        kind: .node(kind: .closureExpr),
        isOptional: true
      ),
      Child(
        name: "AdditionalTrailingClosures",
        kind: .collection(kind: .multipleTrailingClosureElementList, collectionElementName: "AdditionalTrailingClosure"),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .memberBlock,
    base: .syntax,
    nameForDiagnostics: "member block",
    parserFunction: "parseMemberBlock",
    traits: ["Braced"],
    children: [
      Child(
        name: "LeftBrace",
        kind: .token(choices: [.token(tokenKind: "LeftBraceToken")])
      ),
      Child(
        name: "Members",
        kind: .collection(kind: .memberBlockItemList, collectionElementName: "Member")
      ),
      Child(
        name: "RightBrace",
        kind: .token(choices: [.token(tokenKind: "RightBraceToken")])
      ),
    ]
  ),

  // member-decl = decl ';'?
  Node(
    kind: .memberBlockItem,
    base: .syntax,
    nameForDiagnostics: nil,
    documentation: "A member declaration of a type consisting of a declaration and an optional semicolon;",
    children: [
      Child(
        name: "Decl",
        kind: .node(kind: .decl),
        documentation: "The declaration of the type member."
      ),
      Child(
        name: "Semicolon",
        kind: .token(choices: [.token(tokenKind: "SemicolonToken")]),
        documentation: "An optional trailing semicolon.",
        isOptional: true
      ),
    ]
  ),

  // member-decl-list = member-decl member-decl-list?
  Node(
    kind: .memberBlockItemList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.memberBlockItem]
  ),

  // declaration-modifier -> access-level-modifier
  //                       | mutation-modifier
  //                       | 'class'
  //                       | 'convenience'
  //                       | 'distributed'
  //                       | 'dynamic'
  //                       | 'final'
  //                       | 'infix'
  //                       | 'isolated'
  //                       | 'lazy'
  //                       | 'nonisolated'
  //                       | 'optional'
  //                       | 'override'
  //                       | 'postfix'
  //                       | 'prefix'
  //                       | 'required'
  //                       | 'static'
  //                       | 'unowned'
  //                       | 'unowned(safe)'
  //                       | 'unowned(unsafe)'
  //                       | 'weak'
  // mutation-modifier -> 'mutating' | 'nonmutating'
  Node(
    kind: .declModifierList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.declModifier]
  ),

  // operator-decl -> attribute? modifiers? 'operator' operator
  Node(
    kind: .operatorDecl,
    base: .decl,
    nameForDiagnostics: "operator declaration",
    documentation: "A Swift `operator` declaration.",
    traits: [
      "NamedDecl"
    ],
    children: [
      Child(
        name: "FixitySpecifier",
        deprecatedName: "Fixity",
        kind: .token(choices: [.keyword(text: "prefix"), .keyword(text: "postfix"), .keyword(text: "infix")]),
        nameForDiagnostics: "fixity",
        documentation: "The fixity applied to the 'operator' declaration."
      ),
      Child(
        name: "OperatorKeyword",
        kind: .token(choices: [.keyword(text: "operator")])
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "BinaryOperatorToken"), .token(tokenKind: "PrefixOperatorToken"), .token(tokenKind: "PostfixOperatorToken")])
      ),
      Child(
        name: "OperatorPrecedenceAndTypes",
        kind: .node(kind: .operatorPrecedenceAndTypes),
        documentation: "Optionally specify a precedence group and designated types.",
        isOptional: true
      ),
    ]
  ),

  // infix-operator-group -> ':' identifier designated-type-list?
  Node(
    kind: .operatorPrecedenceAndTypes,
    base: .syntax,
    nameForDiagnostics: nil,
    documentation: "A clause to specify precedence group in infix operator declarations, and designated types in any operator declaration.",
    children: [
      Child(
        name: "Colon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "PrecedenceGroup",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        nameForDiagnostics: "precedence group",
        documentation: "The precedence group for this operator"
      ),
      Child(
        name: "DesignatedTypes",
        kind: .collection(kind: .designatedTypeList, collectionElementName: "DesignatedTypeElement"),
        documentation: "The designated types associated with this operator."
      ),
    ]
  ),

  Node(
    kind: .functionParameterClause,
    base: .syntax,
    nameForDiagnostics: "parameter clause",
    traits: [
      "Parenthesized"
    ],
    children: [
      Child(
        name: "LeftParen",
        kind: .token(choices: [.token(tokenKind: "LeftParenToken")])
      ),
      Child(
        name: "Parameters",
        deprecatedName: "ParameterList",
        kind: .collection(kind: .functionParameterList, collectionElementName: "Parameter"),
        nameForDiagnostics: "parameters"
      ),
      Child(
        name: "RightParen",
        kind: .token(choices: [.token(tokenKind: "RightParenToken")])
      ),
    ]
  ),

  Node(
    kind: .patternBindingList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.patternBinding]
  ),

  // Pattern: Type = Value { get {} },
  Node(
    kind: .patternBinding,
    base: .syntax,
    nameForDiagnostics: nil,
    traits: [
      "WithTrailingComma"
    ],
    children: [
      Child(
        name: "Pattern",
        kind: .node(kind: .pattern)
      ),
      Child(
        name: "TypeAnnotation",
        kind: .node(kind: .typeAnnotation),
        nameForDiagnostics: "type annotation",
        isOptional: true
      ),
      Child(
        name: "Initializer",
        kind: .node(kind: .initializerClause),
        isOptional: true
      ),
      Child(
        name: "AccessorBlock",
        deprecatedName: "Accessor",
        kind: .node(kind: .accessorBlock),
        isOptional: true
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")]),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .poundSourceLocationArguments,
    base: .syntax,
    nameForDiagnostics: "'#sourceLocation' arguments",
    children: [
      Child(
        name: "FileLabel",
        deprecatedName: "FileArgLabel",
        kind: .token(choices: [.keyword(text: "file")])
      ),
      Child(
        name: "FileColon",
        deprecatedName: "FileArgColon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "FileName",
        kind: .node(kind: .stringLiteralExpr),
        nameForDiagnostics: "file name"
      ),
      Child(
        name: "Comma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")])
      ),
      Child(
        name: "LineLabel",
        deprecatedName: "LineArgLabel",
        kind: .token(choices: [.keyword(text: "line")])
      ),
      Child(
        name: "LineColon",
        deprecatedName: "LineArgColon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "LineNumber",
        kind: .token(choices: [.token(tokenKind: "IntegerLiteralToken")]),
        nameForDiagnostics: "line number"
      ),
    ]
  ),

  Node(
    kind: .poundSourceLocation,
    base: .decl,
    nameForDiagnostics: "'#sourceLocation' directive",
    traits: [
      "Parenthesized"
    ],
    children: [
      Child(
        name: "PoundSourceLocation",
        kind: .token(choices: [.token(tokenKind: "PoundSourceLocationToken")])
      ),
      Child(
        name: "LeftParen",
        kind: .token(choices: [.token(tokenKind: "LeftParenToken")])
      ),
      Child(
        name: "Arguments",
        deprecatedName: "Args",
        kind: .node(kind: .poundSourceLocationArguments),
        nameForDiagnostics: "arguments",
        isOptional: true
      ),
      Child(
        name: "RightParen",
        kind: .token(choices: [.token(tokenKind: "RightParenToken")])
      ),
    ]
  ),

  // precedence-group-assignment ->
  //     'assignment' ':' ('true' | 'false')
  Node(
    kind: .precedenceGroupAssignment,
    base: .syntax,
    nameForDiagnostics: "'assignment' property of precedencegroup",
    documentation: "Specifies the precedence of an operator when used in an operation that includes optional chaining.",
    children: [
      Child(
        name: "AssignmentLabel",
        deprecatedName: "AssignmentKeyword",
        kind: .token(choices: [.keyword(text: "assignment")])
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "Value",
        deprecatedName: "Flag",
        kind: .token(choices: [.keyword(text: "true"), .keyword(text: "false")]),
        documentation:
          "When true, an operator in the corresponding precedence group uses the same grouping rules during optional chaining as the assignment operators from the standard library. Otherwise, operators in the precedence group follows the same optional chaining rules as operators that don't perform assignment."
      ),
    ]
  ),

  // precedence-group-associativity ->
  //     'associativity' ':' ('left' | 'right' | 'none')
  Node(
    kind: .precedenceGroupAssociativity,
    base: .syntax,
    nameForDiagnostics: "'associativity' property of precedencegroup",
    documentation: "Specifies how a sequence of operators with the same precedence level are grouped together in the absence of grouping parentheses.",
    children: [
      Child(
        name: "AssociativityLabel",
        deprecatedName: "AssociativityKeyword",
        kind: .token(choices: [.keyword(text: "associativity")])
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "Value",
        kind: .token(choices: [.keyword(text: "left"), .keyword(text: "right"), .keyword(text: "none")]),
        documentation:
          "Operators that are `left`-associative group left-to-right. Operators that are `right`-associative group right-to-left. Operators that are specified with an associativity of `none` don't associate at all"
      ),
    ]
  ),
  // precedence-group-attribute-list ->
  //     (precedence-group-relation | precedence-group-assignment |
  //      precedence-group-associativity )*
  Node(
    kind: .precedenceGroupAttributeList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.precedenceGroupRelation, .precedenceGroupAssignment, .precedenceGroupAssociativity]
  ),

  // precedence-group-decl -> attributes? modifiers? 'precedencegroup'
  //                            identifier '{' precedence-group-attribute-list
  //                            '}'
  Node(
    kind: .precedenceGroupDecl,
    base: .decl,
    nameForDiagnostics: "precedencegroup",
    documentation: "A Swift `precedencegroup` declaration.",
    traits: [
      "NamedDecl",
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "The attributes applied to the 'precedencegroup' declaration.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "The declaration modifiers applied to the 'precedencegroup' declaration.",
        isOptional: true
      ),
      Child(
        name: "PrecedencegroupKeyword",
        kind: .token(choices: [.keyword(text: "precedencegroup")])
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: "The name of this precedence group."
      ),
      Child(
        name: "LeftBrace",
        kind: .token(choices: [.token(tokenKind: "LeftBraceToken")])
      ),
      Child(
        name: "GroupAttributes",
        kind: .collection(kind: .precedenceGroupAttributeList, collectionElementName: "GroupAttribute"),
        documentation: "The characteristics of this precedence group."
      ),
      Child(
        name: "RightBrace",
        kind: .token(choices: [.token(tokenKind: "RightBraceToken")])
      ),
    ]
  ),

  Node(
    kind: .precedenceGroupName,
    base: .syntax,
    nameForDiagnostics: nil,
    traits: ["WithTrailingComma"],
    children: [
      Child(
        name: "Name",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        nameForDiagnostics: "name"
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(tokenKind: "CommaToken")]),
        isOptional: true
      ),
    ]
  ),

  // precedence-group-name-list ->
  //    identifier (',' identifier)*
  Node(
    kind: .precedenceGroupNameList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.precedenceGroupName]
  ),

  // precedence-group-relation ->
  //     ('higherThan' | 'lowerThan') ':' precedence-group-name-list
  Node(
    kind: .precedenceGroupRelation,
    base: .syntax,
    nameForDiagnostics: "'relation' property of precedencegroup",
    documentation: "Specify the new precedence group's relation to existing precedence groups.",
    children: [
      Child(
        name: "HigherThanOrLowerThanLabel",
        deprecatedName: "HigherThanOrLowerThan",
        kind: .token(choices: [.keyword(text: "higherThan"), .keyword(text: "lowerThan")]),
        documentation: "The relation to specified other precedence groups."
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "PrecedenceGroups",
        deprecatedName: "OtherNames",
        kind: .collection(kind: .precedenceGroupNameList, collectionElementName: "OtherName"),
        documentation: "The name of other precedence group to which this precedence group relates."
      ),
    ]
  ),

  Node(
    kind: .protocolDecl,
    base: .decl,
    nameForDiagnostics: "protocol",
    documentation: """
      A protocol declaration like the following.

      ```swift
      protocol Example {
        var isValid: Bool { get }
      }
      ```
      """,
    traits: [
      "DeclGroup",
      "NamedDecl",
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "Attributes attached to the protocol declaration, such as an `@available` attribute.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "Modifiers attached to the protocol declaration, such as `public`.",
        isOptional: true
      ),
      Child(
        name: "ProtocolKeyword",
        kind: .token(choices: [.keyword(text: "protocol")]),
        documentation: "The `protocol` keyword for this declaration."
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: "The name of the protocol."
      ),
      Child(
        name: "PrimaryAssociatedTypeClause",
        kind: .node(kind: .primaryAssociatedTypeClause),
        nameForDiagnostics: "primary associated type clause",
        documentation: "The primary associated type for the protocol.",
        isOptional: true
      ),
      Child(
        name: "InheritanceClause",
        kind: .node(kind: .inheritanceClause),
        nameForDiagnostics: "inheritance clause",
        documentation: "The inheritance clause describing one or more conformances for this protocol declaration.",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "The `where` clause that applies to the generic parameters of this protocol declaration.",
        isOptional: true
      ),
      Child(
        name: "MemberBlock",
        kind: .node(kind: .memberBlock),
        documentation: "The members of the protocol declaration."
      ),
    ]
  ),

  // return-clause ->
  //   '->' type
  Node(
    kind: .returnClause,
    base: .syntax,
    nameForDiagnostics: nil,
    children: [
      Child(
        name: "Arrow",
        kind: .token(choices: [.token(tokenKind: "ArrowToken")])
      ),
      Child(
        name: "Type",
        deprecatedName: "ReturnType",
        kind: .node(kind: .type),
        nameForDiagnostics: "return type"
      ),
    ]
  ),

  // source-file = code-block-item-list endOfFile
  Node(
    kind: .sourceFile,
    base: .syntax,
    nameForDiagnostics: "source file",
    parserFunction: "parseSourceFile",
    traits: ["WithStatements"],
    children: [
      Child(
        name: "Statements",
        kind: .collection(kind: .codeBlockItemList, collectionElementName: "Statement")
      ),
      Child(
        name: "EndOfFileToken",
        deprecatedName: "EOFToken",
        kind: .token(choices: [.token(tokenKind: "EndOfFileToken")])
      ),
    ]
  ),

  // struct-declaration -> attributes? access-level-modifier?
  //                         'struct' struct-name
  //                         generic-parameter-clause?
  //                           type-inheritance-clause?
  //                         generic-where-clause?
  //                         '{' struct-members '}'
  // struct-name -> identifier
  Node(
    kind: .structDecl,
    base: .decl,
    nameForDiagnostics: "struct",
    documentation: """
          A struct declaration like the following.

          ```swift
          struct SomeStruct {
            let someMember: String
            var anotherMember: Int

            func foo() {
              print(someMember)
            }

            mutating func bar() {
              anotherMember = 42
            }
          }
          ```

          A struct declaration may be declared without any members.

          ```swift
          struct EmptyStruct {

          }
          ```

          A struct declaration may include a type inheritance clause listing
          one or more protocols the struct conforms to.

          The example below uses Hashable and Equatable protocols whose members
          are automatically synthesized by the compiler if the struct contains
          stored members that are themselves `Hashable` and `Equatable`.

          ```swift
          struct AdvancedStruct: Hashable, Equatable {
            let someMember: String
            var anotherMember: Int
          }
          ```

          A struct declaration may include a generic parameter clause as well
          as a generic where clause.

          ```swift
          struct Stack<Element> {
            var items: [Element] = []

            mutating func push(_ item: Element) {
              items.append(item)
            }

            mutating func pop() -> Element {
              return items.removeLast()
            }
         }
         ```
      """,
    traits: [
      "DeclGroup",
      "NamedDecl",
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        documentation: "Attributes that are attached to the struct declaration.",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        documentation: "Modifiers that are attached to the struct declaration.",
        isOptional: true
      ),
      Child(
        name: "StructKeyword",
        kind: .token(choices: [.keyword(text: "struct")]),
        documentation: "The `struct` keyword for this declaration."
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")]),
        documentation: "Declares the name of this struct. If the name matches a reserved keyword use backticks to escape it."
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The generic parameters, if any, of the struct declaration.",
        isOptional: true
      ),
      Child(
        name: "InheritanceClause",
        kind: .node(kind: .inheritanceClause),
        nameForDiagnostics: "inheritance clause",
        documentation: "The struct declaration inheritance clause describing one or more conformances for this struct declaration.",
        isOptional: true
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "The `where` clause that applies to the generic parameters of this struct declaration.",
        isOptional: true
      ),
      Child(
        name: "MemberBlock",
        kind: .node(kind: .memberBlock),
        documentation:
          "The members of the struct declaration. Because struct extension declarations may declare additional members the contents of this member block isn't guaranteed to be a complete list of members for this type."
      ),
    ]
  ),

  Node(
    kind: .subscriptDecl,
    base: .decl,
    nameForDiagnostics: "subscript",
    traits: [
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "SubscriptKeyword",
        kind: .token(choices: [.keyword(text: "subscript")])
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The parameter clause that defines the generic parameters.",
        isOptional: true
      ),
      Child(
        name: "ParameterClause",
        deprecatedName: "Indices",
        kind: .node(kind: .functionParameterClause)
      ),
      Child(
        name: "ReturnClause",
        deprecatedName: "Result",
        kind: .node(kind: .returnClause)
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
        isOptional: true
      ),
      Child(
        name: "AccessorBlock",
        deprecatedName: "Accessor",
        kind: .node(kind: .accessorBlock),
        isOptional: true
      ),
    ]
  ),

  // type-inheritance-clause -> ':' type
  Node(
    kind: .inheritanceClause,
    base: .syntax,
    nameForDiagnostics: "inheritance clause",
    children: [
      Child(
        name: "Colon",
        kind: .token(choices: [.token(tokenKind: "ColonToken")])
      ),
      Child(
        name: "InheritedTypes",
        deprecatedName: "InheritedTypeCollection",
        kind: .collection(kind: .inheritedTypeList, collectionElementName: "InheritedType")
      ),
    ]
  ),

  // type-assignment -> '=' type
  Node(
    kind: .typeInitializerClause,
    base: .syntax,
    nameForDiagnostics: nil,
    children: [
      Child(
        name: "Equal",
        kind: .token(choices: [.token(tokenKind: "EqualToken")])
      ),
      Child(
        name: "Value",
        kind: .node(kind: .type),
        nameForDiagnostics: "type"
      ),
    ]
  ),

  // typealias-declaration -> attributes? access-level-modifier? 'typealias'
  //                            typealias-name generic-parameter-clause?
  //                            type-assignment
  // typealias-name -> identifier
  Node(
    kind: .typeAliasDecl,
    base: .decl,
    nameForDiagnostics: "typealias declaration",
    traits: [
      "NamedDecl",
      "WithAttributes",
      "WithGenericParameters",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "TypealiasKeyword",
        kind: .token(choices: [.keyword(text: "typealias")])
      ),
      Child(
        name: "Name",
        deprecatedName: "Identifier",
        kind: .token(choices: [.token(tokenKind: "IdentifierToken")])
      ),
      Child(
        name: "GenericParameterClause",
        kind: .node(kind: .genericParameterClause),
        nameForDiagnostics: "generic parameter clause",
        documentation: "The parameter clause that defines the generic parameters.",
        isOptional: true
      ),
      Child(
        name: "Initializer",
        kind: .node(kind: .typeInitializerClause)
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        nameForDiagnostics: "generic where clause",
        documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .variableDecl,
    base: .decl,
    nameForDiagnostics: "variable",
    traits: [
      "WithAttributes",
      "WithModifiers",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute"),
        nameForDiagnostics: "attributes",
        isOptional: true
      ),
      Child(
        name: "Modifiers",
        kind: .collection(kind: .declModifierList, collectionElementName: "Modifier"),
        nameForDiagnostics: "modifiers",
        isOptional: true
      ),
      Child(
        name: "BindingSpecifier",
        deprecatedName: "BindingKeyword",
        kind: .token(choices: [.keyword(text: "let"), .keyword(text: "var"), .keyword(text: "inout")])
      ),
      Child(
        name: "Bindings",
        kind: .collection(kind: .patternBindingList, collectionElementName: "Binding")
      ),
    ]
  ),

]
