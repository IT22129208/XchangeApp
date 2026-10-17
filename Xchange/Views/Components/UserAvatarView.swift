//
//  UserAvatarView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Universal Avatar Component Supporting Local Images, Sandbox Photos, and SF Symbols
//

import SwiftUI
import UIKit

public struct UserAvatarView: View {
    public let avatar: String
    public var fallbackImage: UIImage? = nil
    public var size: CGFloat = 44
    public var accentColor: Color = AppTheme.primary
    public var showBorder: Bool = false
    public var borderColor: Color = AppTheme.primary
    public var borderWidth: CGFloat = 1.5
    
    public init(
        avatar: String,
        fallbackImage: UIImage? = nil,
        size: CGFloat = 44,
        accentColor: Color = AppTheme.primary,
        showBorder: Bool = false,
        borderColor: Color = AppTheme.primary,
        borderWidth: CGFloat = 1.5
    ) {
        self.avatar = avatar
        self.fallbackImage = fallbackImage
        self.size = size
        self.accentColor = accentColor
        self.showBorder = showBorder
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    public var body: some View {
        avatarContent
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Group {
                    if showBorder {
                        Circle()
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                }
            )
    }
    
    @ViewBuilder
    private var avatarContent: some View {
        if let explicit = fallbackImage {
            Image(uiImage: explicit)
                .resizable()
                .scaledToFill()
        } else if let customImg = PersistenceService.shared.resolveImage(nameOrPath: avatar) {
            Image(uiImage: customImg)
                .resizable()
                .scaledToFill()
        } else if UIImage(named: avatar) != nil {
            Image(avatar)
                .resizable()
                .scaledToFill()
        } else if UIImage(named: "user_avatar_profile") != nil && (avatar.isEmpty || avatar == "user_avatar_profile") {
            Image("user_avatar_profile")
                .resizable()
                .scaledToFill()
        } else {
            let symbol = avatar.isEmpty ? "person.crop.circle.fill" : avatar
            Image(systemName: symbol)
                .font(.system(size: size * 0.58))
                .foregroundColor(accentColor)
                .frame(width: size, height: size)
                .background(accentColor.opacity(0.12))
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        UserAvatarView(avatar: "person.crop.circle.fill", size: 50)
        UserAvatarView(avatar: "camera.circle.fill", size: 50, showBorder: true)
    }
    .padding()
}
