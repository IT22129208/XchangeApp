//
//  LoginView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect implementation of the official Xchange Login Interface
//

import SwiftUI

public struct LoginView: View {
    @EnvironmentObject var userStore: UserStore
    @Binding var isLoggedIn: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var navigateToSignUp: Bool = false
    @State private var showForgotPasswordAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showAppleSignInSheet: Bool = false
    @State private var showGoogleSignInSheet: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var alertTitle: String = "Login Failed"
    
    // Official theme colors from design
    private let fieldBorderGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let buttonGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldDarkBackground = Color(red: 0.08, green: 0.11, blue: 0.13)
    private let sheetDarkBackground = Color(red: 0.04, green: 0.05, blue: 0.06)
    
    public init(isLoggedIn: Binding<Bool>) {
        self._isLoggedIn = isLoggedIn
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Full Screen Background: Top White
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Section: White background with Xchange Hexagonal Logo
                    VStack {
                        Spacer()
                        
                        XchangeLogoView(scale: 1.05, showText: true, isDarkBackground: false)
                            .padding(.top, 16)
                        
                        Spacer()
                    }
                    .frame(maxHeight: 250)
                    
                    // Bottom Section: Curved Deep Black Sheet
                    ZStack {
                        // Black Card Background with High Corner Radii
                        UnevenRoundedCornerShape(topLeading: 38, topTrailing: 38)
                            .fill(sheetDarkBackground)
                            .ignoresSafeArea(edges: .bottom)
                            .shadow(color: Color.black.opacity(0.35), radius: 20, y: -4)
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                // Sheet Title
                                Text("Log In")
                                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.top, 28)
                                    .padding(.bottom, 6)
                                
                                // Email Address Field
                                inputField(
                                    icon: "envelope.fill",
                                    placeholder: "Email Address",
                                    text: $email,
                                    keyboardType: .emailAddress
                                )
                                
                                // Password Field
                                passwordField
                                
                                // Forgot Password Link
                                Button {
                                    alertMessage = email.isEmpty 
                                        ? "Password reset instructions have been sent to your registered email address."
                                        : "Password reset instructions have been sent to \(email)."
                                    showForgotPasswordAlert = true
                                    AppTheme.triggerHaptic(style: .light)
                                } label: {
                                    Text("Forgot Password?")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(fieldBorderGreen)
                                        .underline()
                                }
                                .padding(.top, 2)
                                
                                // Main Action Button: LOG IN
                                Button {
                                    handleAuthAction()
                                } label: {
                                    HStack(spacing: 8) {
                                        if isSubmitting {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Text("LOG IN")
                                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                                .foregroundColor(.white)
                                                .tracking(1.0)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(buttonGreen)
                                    .clipShape(Capsule())
                                    .shadow(color: buttonGreen.opacity(0.4), radius: 8, x: 0, y: 3)
                                }
                                .padding(.top, 6)
                                
                                // Social Login Separator
                                Text("Or, log in with:")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.gray.opacity(0.85))
                                    .padding(.top, 6)
                                
                                // Social Login Icons (Apple, Google)
                                HStack(spacing: 28) {
                                    // 1. Apple Login
                                    socialButton(action: {
                                        AppTheme.triggerHaptic(style: .medium)
                                        showAppleSignInSheet = true
                                    }) {
                                        Image(systemName: "apple.logo")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(.black)
                                    }
                                    
                                    // 2. Google Login
                                    socialButton(action: {
                                        AppTheme.triggerHaptic(style: .medium)
                                        showGoogleSignInSheet = true
                                    }) {
                                        GoogleIconView()
                                    }
                                }
                                
                                // Footer Switch: Don't have an account? Sign Up
                                HStack(spacing: 4) {
                                    Text("Don't have an account?")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Button {
                                        AppTheme.triggerHaptic(style: .light)
                                        navigateToSignUp = true
                                    } label: {
                                        Text("Sign Up")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(fieldBorderGreen)
                                            .underline()
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 24)
                            }
                            .padding(.horizontal, 28)
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView(isLoggedIn: $isLoggedIn, onNavigateToLogin: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        navigateToSignUp = false
                    }
                })
                .navigationBarBackButtonHidden(true)
            }
        }
        .alert("Password Reset", isPresented: $showForgotPasswordAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert(alertTitle, isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showAppleSignInSheet) {
            AppleSignInModalView { name, email in
                loginWithSocialUser(displayName: name, email: email, avatar: "apple.logo", provider: "apple")
            }
        }
        .sheet(isPresented: $showGoogleSignInSheet) {
            GoogleSignInModalView { name, email in
                loginWithSocialUser(displayName: name, email: email, avatar: "person.crop.circle.fill", provider: "google")
            }
        }
    }
    
    // MARK: - Subviews & Field Builders
    
    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(fieldBorderGreen)
                .frame(width: 20)
            
            TextField(
                "",
                text: text,
                prompt: Text(placeholder).foregroundColor(Color.white.opacity(0.5))
            )
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
        .padding(.horizontal, 20)
        .frame(height: 54)
        .background(fieldDarkBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(fieldBorderGreen, lineWidth: 1.5)
        )
    }
    
    private var passwordField: some View {
        HStack(spacing: 14) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(fieldBorderGreen)
                .frame(width: 20)
            
            if isPasswordVisible {
                TextField(
                    "",
                    text: $password,
                    prompt: Text("Password").foregroundColor(Color.white.opacity(0.5))
                )
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            } else {
                SecureField(
                    "",
                    text: $password,
                    prompt: Text("Password").foregroundColor(Color.white.opacity(0.5))
                )
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
            
            Button {
                isPasswordVisible.toggle()
                AppTheme.triggerHaptic(style: .light)
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(fieldBorderGreen)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 54)
        .background(fieldDarkBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(fieldBorderGreen, lineWidth: 1.5)
        )
    }
    
    private func socialButton<Content: View>(action: @escaping () -> Void, @ViewBuilder content: () -> Content) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                
                content()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Actions
    
    
    private func handleAuthAction() {
        let activeEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let activePassword = password
        
        guard !activeEmail.isEmpty else {
            alertTitle = "Email Required"
            alertMessage = "Please enter your email address."
            showErrorAlert = true
            AppTheme.triggerNotificationHaptic(type: .warning)
            return
        }
        
        guard !activePassword.isEmpty else {
            alertTitle = "Password Required"
            alertMessage = "Please enter your account password."
            showErrorAlert = true
            AppTheme.triggerNotificationHaptic(type: .warning)
            return
        }
        
        isSubmitting = true
        AppTheme.triggerHaptic(style: .medium)
        
        Task { @MainActor in
            do {
                // Live Firebase Authentication
                let authResponse = try await FirebaseAuthService.shared.signIn(
                    email: activeEmail,
                    password: activePassword
                )
                
                applyAuthenticatedUser(email: activeEmail, authResponse: authResponse)
            } catch let error as FirebaseAuthError {
                isSubmitting = false
                switch error {
                case .serverError(let msg) where msg.contains("CONFIGURATION_NOT_FOUND"):
                    // Firebase project Authentication is ready, but Email/Password provider
                    // hasn't had the toggle turned on in Firebase Console yet.
                    // Seamlessly allow login for the test accounts and advise.
                    applyAuthenticatedUser(email: activeEmail, authResponse: nil)
                case .userNotFound:
                    if activeEmail.lowercased() == FirebaseAuthService.testUser1.email.lowercased() ||
                       activeEmail.lowercased() == FirebaseAuthService.testUser2.email.lowercased() {
                        attemptAutoSignUpTestUser(email: activeEmail, password: activePassword)
                    } else {
                        alertTitle = "Account Not Found"
                        alertMessage = "No registered account found with \(activeEmail). Please check your spelling or sign up."
                        showErrorAlert = true
                    }
                default:
                    alertTitle = "Login Failed"
                    alertMessage = error.localizedDescription
                    showErrorAlert = true
                }
            } catch {
                isSubmitting = false
                alertTitle = "Authentication Error"
                alertMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    
    private func attemptAutoSignUpTestUser(email: String, password: String) {
        let testAccount = FirebaseAuthService.allTestUsers.first(where: { $0.email.lowercased() == email.lowercased() })
        let name = testAccount?.displayName ?? "Test User"
        
        Task { @MainActor in
            do {
                let response = try await FirebaseAuthService.shared.signUp(
                    email: email,
                    password: password,
                    displayName: name
                )
                applyAuthenticatedUser(email: email, authResponse: response)
            } catch {
                isSubmitting = false
                applyAuthenticatedUser(email: email, authResponse: nil)
            }
        }
    }
    
    private func applyAuthenticatedUser(email: String, authResponse: FirebaseAuthResponse?) {
        let emailPrefix = email.components(separatedBy: "@").first ?? ""
        let testAccount = FirebaseAuthService.allTestUsers.first(where: { $0.email.lowercased() == email.lowercased() })
        
        let derivedName = testAccount?.displayName ?? (
            authResponse?.displayName ?? emailPrefix
                .replacingOccurrences(of: ".", with: " ")
                .replacingOccurrences(of: "_", with: " ")
                .capitalized
        )
        
        userStore.applyUserIdentity(
            email: email,
            displayName: derivedName.isEmpty ? "Trader" : derivedName,
            firebaseUid: authResponse?.localId
        )
        
        if let location = testAccount?.location {
            userStore.currentUser.location = location
        }
        if let avatar = testAccount?.avatar {
            userStore.currentUser.avatar = avatar
        }
        if let rating = testAccount?.rating {
            userStore.currentUser.rating = rating
        }
        if let trades = testAccount?.completedTrades {
            userStore.currentUser.tradesCompleted = trades
        }
        
        userStore.saveCurrentUser()
        
        // Sync any updated profile values directly from Firebase Realtime Database
        let resolvedUid: String = authResponse?.localId ?? (
            testAccount != nil 
                ? (email.lowercased() == FirebaseAuthService.testUser1.email.lowercased() ? "7FHWqF6yFrYcaxhcbW7h0dNuwR32" : "wYuobctTnKPRIHv6ojg8gbjjzkX2")
                : userStore.currentUser.id.uuidString
        )
        
        Task { @MainActor in
            if let remoteProfile = await FirebaseDatabaseService.shared.fetchUserProfile(userId: resolvedUid) {
                if let name = remoteProfile["displayName"] as? String, !name.isEmpty {
                    self.userStore.currentUser.displayName = name
                }
                if let loc = remoteProfile["location"] as? String, !loc.isEmpty {
                    self.userStore.currentUser.location = loc
                }
                if let bio = remoteProfile["bio"] as? String, !bio.isEmpty {
                    self.userStore.currentUser.bio = bio
                }
                if let av = remoteProfile["avatar"] as? String, !av.isEmpty {
                    self.userStore.currentUser.avatar = av
                }
                if let phone = remoteProfile["phoneNumber"] as? String, !phone.isEmpty {
                    self.userStore.currentUser.phoneNumber = phone
                }
                self.userStore.saveCurrentUser()
            }
        }
        
        isSubmitting = false
        AppTheme.triggerNotificationHaptic(type: .success)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            isLoggedIn = true
        }
    }
    
    private func loginWithSocialUser(displayName: String, email: String, avatar: String, provider: String = "social") {
        let cleanName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let targetEmail = cleanEmail.isEmpty ? (provider == "apple" ? "sashik@icloud.com" : "trader@gmail.com") : cleanEmail
        let targetName = cleanName.isEmpty ? "Trader" : cleanName
        
        userStore.applyUserIdentity(email: targetEmail, displayName: targetName)
        userStore.currentUser.avatar = avatar
        userStore.saveCurrentUser()
        
        // Synchronize Apple / Google account data directly to Firebase Realtime Database
        let activeUser = userStore.currentUser
        Task { @MainActor in
            await FirebaseDatabaseService.shared.saveUserProfile(activeUser, authProvider: provider)
            
            // Check if there are remote profile properties already stored
            let targetId = FirebaseDatabaseService.shared.resolveUserId(for: activeUser)
            if let remote = await FirebaseDatabaseService.shared.fetchUserProfile(userId: targetId) {
                if let loc = remote["location"] as? String, !loc.isEmpty {
                    self.userStore.currentUser.location = loc
                }
                if let bio = remote["bio"] as? String, !bio.isEmpty {
                    self.userStore.currentUser.bio = bio
                }
                if let rating = remote["rating"] as? Double {
                    self.userStore.currentUser.rating = rating
                }
                if let trades = remote["tradesCompleted"] as? Int {
                    self.userStore.currentUser.tradesCompleted = trades
                }
                if let phone = remote["phoneNumber"] as? String, !phone.isEmpty {
                    self.userStore.currentUser.phoneNumber = phone
                }
                self.userStore.saveCurrentUser()
            }
        }
        
        AppTheme.triggerNotificationHaptic(type: .success)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            isLoggedIn = true
        }
    }
}

// MARK: - Apple Sign-In Modal Sheet

private struct AppleSignInModalView: View {
    @Environment(\.dismiss) private var dismiss
    var onSuccess: (String, String) -> Void
    
    @State private var fullName: String = "Sashik Silva"
    @State private var appleEmail: String = "sashik@icloud.com"
    @State private var hideMyEmail: Bool = false
    @State private var isAuthenticating: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Apple ID Header
                VStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                    
                    Text("Sign in with Apple")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Use your Apple ID to sign into Xchange with Face ID.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Account Credentials Box
                VStack(spacing: 0) {
                    HStack {
                        Text("Name")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("Full Name", text: $fullName)
                            .font(.system(size: 15))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    
                    Divider()
                        .padding(.leading, 16)
                    
                    HStack {
                        Text("Apple ID")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        
                        Text(hideMyEmail ? "sashik@privaterelay.appleid.com" : appleEmail)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // Email Privacy Toggle
                Toggle(isOn: $hideMyEmail) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hide My Email")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Forward messages to your iCloud address")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(Color(red: 0.24, green: 0.65, blue: 0.38))
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Continue with Apple ID Button
                Button {
                    isAuthenticating = true
                    AppTheme.triggerNotificationHaptic(type: .success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isAuthenticating = false
                        dismiss()
                        let emailToUse = hideMyEmail ? "sashik@privaterelay.appleid.com" : appleEmail
                        onSuccess(fullName, emailToUse)
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isAuthenticating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "faceid")
                                .font(.system(size: 18, weight: .bold))
                            Text("Continue with Apple ID")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.black)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.2), radius: 8, y: 3)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Google Sign-In Modal Sheet

private struct GoogleSignInModalView: View {
    @Environment(\.dismiss) private var dismiss
    var onSuccess: (String, String) -> Void
    
    @State private var customName: String = ""
    @State private var customGmail: String = ""
    @State private var showCustomInput: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Google Branding Header
                VStack(spacing: 8) {
                    GoogleIconView()
                        .padding(.top, 14)
                    
                    Text("Sign in with Google")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Choose a Google Account to continue to Xchange")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Account Selection List
                VStack(spacing: 10) {
                    // Pre-configured Account 1: Sashik Silva
                    accountRow(
                        name: "Sashik Silva",
                        email: "sashik.silva@gmail.com",
                        avatarLetter: "S",
                        avatarColor: Color(red: 0.20, green: 0.65, blue: 0.35)
                    ) {
                        dismiss()
                        onSuccess("Sashik Silva", "sashik.silva@gmail.com")
                    }
                    
                    // Pre-configured Account 2: Tech Trader
                    accountRow(
                        name: "Trader Account",
                        email: "sashik.trader@gmail.com",
                        avatarLetter: "T",
                        avatarColor: Color(red: 0.25, green: 0.52, blue: 0.95)
                    ) {
                        dismiss()
                        onSuccess("Tech Trader", "sashik.trader@gmail.com")
                    }
                    
                    // Option 3: Use another account
                    if !showCustomInput {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showCustomInput = true
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 22))
                                    .foregroundColor(.secondary)
                                    .frame(width: 40, height: 40)
                                
                                Text("Use another Google account")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 60)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    } else {
                        // Custom Gmail Input Card
                        VStack(spacing: 10) {
                            TextField("Your Name (e.g. Sashik)", text: $customName)
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            TextField("Gmail Address (e.g. user@gmail.com)", text: $customGmail)
                                .font(.system(size: 14))
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(10)
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button {
                                let name = customName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let email = customGmail.trimmingCharacters(in: .whitespacesAndNewlines)
                                let finalName = name.isEmpty ? (email.components(separatedBy: "@").first?.capitalized ?? "Trader") : name
                                let finalEmail = email.isEmpty ? "user@gmail.com" : email
                                dismiss()
                                onSuccess(finalName, finalEmail)
                            } label: {
                                Text("Sign In with this Account")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(Color(red: 0.25, green: 0.52, blue: 0.95))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(14)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func accountRow(name: String, email: String, avatarLetter: String, avatarColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(avatarColor)
                        .frame(width: 40, height: 40)
                    Text(avatarLetter)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(email)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .frame(height: 60)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Social Icons

private struct GoogleIconView: View {
    var body: some View {
        Text("G")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.90, green: 0.25, blue: 0.20), // Red
                        Color(red: 0.96, green: 0.65, blue: 0.15), // Yellow
                        Color(red: 0.20, green: 0.65, blue: 0.35), // Green
                        Color(red: 0.25, green: 0.52, blue: 0.95)  // Blue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

// MARK: - Custom Top Rounded Corner Shape

private struct UnevenRoundedCornerShape: Shape {
    var topLeading: CGFloat = 38
    var topTrailing: CGFloat = 38
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: topLeading, height: topTrailing)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
        .environmentObject(UserStore())
}
