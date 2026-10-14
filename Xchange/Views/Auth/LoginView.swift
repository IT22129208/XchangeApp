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
                                    .padding(.top, 32)
                                
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
                                
                                // Social Login Icons (Apple, Google, Facebook)
                                HStack(spacing: 22) {
                                    // 1. Apple Login
                                    socialButton {
                                        Image(systemName: "apple.logo")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(.black)
                                    }
                                    
                                    // 2. Google Login
                                    socialButton {
                                        GoogleIconView()
                                    }
                                    
                                    // 3. Facebook Login
                                    socialButton {
                                        FacebookIconView()
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
    
    private func socialButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        Button {
            simulateSocialLogin()
        } label: {
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
        isSubmitting = true
        AppTheme.triggerNotificationHaptic(type: .success)
        
        // Instant simulated transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let activeEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "sashik@xchange.app" : email
            userStore.currentUser.email = activeEmail
            userStore.saveCurrentUser()
            isSubmitting = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                isLoggedIn = true
            }
        }
    }
    
    private func simulateSocialLogin() {
        AppTheme.triggerHaptic(style: .medium)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            isLoggedIn = true
        }
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

private struct FacebookIconView: View {
    var body: some View {
        Text("f")
            .font(.system(size: 24, weight: .black, design: .rounded))
            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.92))
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
