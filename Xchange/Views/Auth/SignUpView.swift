//
//  SignUpView.swift
//  Xchange
//
//  Created for Xchange - Peer-to-Peer Barter App
//  Pixel-perfect implementation of the official Xchange Sign Up Interface
//

import SwiftUI

public struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userStore: UserStore
    @Binding var isLoggedIn: Bool
    var onNavigateToLogin: (() -> Void)? = nil
    
    @State private var fullName: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showTermsSheet: Bool = false
    @State private var isSubmitting: Bool = false
    
    // Official theme colors from design
    private let fieldBorderGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let buttonGreen = Color(red: 0.24, green: 0.65, blue: 0.38)
    private let fieldDarkBackground = Color(red: 0.08, green: 0.11, blue: 0.13)
    private let sheetDarkBackground = Color(red: 0.04, green: 0.05, blue: 0.06)
    
    public init(isLoggedIn: Binding<Bool>, onNavigateToLogin: (() -> Void)? = nil) {
        self._isLoggedIn = isLoggedIn
        self.onNavigateToLogin = onNavigateToLogin
    }
    
    public var body: some View {
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
                .frame(maxHeight: 210)
                
                // Bottom Section: Curved Deep Black Sheet
                ZStack {
                    // Black Card Background with High Corner Radii
                    UnevenRoundedCornerShape(topLeading: 38, topTrailing: 38)
                        .fill(sheetDarkBackground)
                        .ignoresSafeArea(edges: .bottom)
                        .shadow(color: Color.black.opacity(0.35), radius: 20, y: -4)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            // Sheet Title
                            Text("Sign Up")
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 28)
                                .padding(.bottom, 4)
                            
                            // 1. Full Name Field
                            inputField(
                                icon: "person.fill",
                                placeholder: "Full Name",
                                text: $fullName
                            )
                            
                            // 2. Username Field
                            inputField(
                                icon: "at",
                                placeholder: "Username",
                                text: $username,
                                autocapitalization: .never
                            )
                            
                            // 3. Email Address Field
                            inputField(
                                icon: "envelope.fill",
                                placeholder: "Email Address",
                                text: $email,
                                keyboardType: .emailAddress,
                                autocapitalization: .never
                            )
                            
                            // 4. Password Field
                            secureInputField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password
                            )
                            
                            // 5. Confirm Password Field
                            secureInputField(
                                icon: "lock.fill",
                                placeholder: "Confirm Password",
                                text: $confirmPassword
                            )
                            
                            // Main Action Button: CREATE ACCOUNT
                            Button {
                                handleSignUpAction()
                            } label: {
                                HStack(spacing: 8) {
                                    if isSubmitting {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("CREATE ACCOUNT")
                                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                                            .foregroundColor(.white)
                                            .tracking(1.0)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(buttonGreen)
                                .clipShape(Capsule())
                                .shadow(color: buttonGreen.opacity(0.4), radius: 8, x: 0, y: 3)
                            }
                            .padding(.top, 6)
                            
                            // Terms & Conditions / Privacy Policy Agreement Disclaimer
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Text("By signing up, you agree to our")
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    Button {
                                        showTermsSheet = true
                                        AppTheme.triggerHaptic(style: .light)
                                    } label: {
                                        Text("Terms")
                                            .foregroundColor(fieldBorderGreen)
                                            .underline()
                                    }
                                }
                                
                                HStack(spacing: 4) {
                                    Button {
                                        showTermsSheet = true
                                        AppTheme.triggerHaptic(style: .light)
                                    } label: {
                                        Text("& Conditions")
                                            .foregroundColor(fieldBorderGreen)
                                            .underline()
                                    }
                                    
                                    Text("and")
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    Button {
                                        showTermsSheet = true
                                        AppTheme.triggerHaptic(style: .light)
                                    } label: {
                                        Text("Privacy Policy.")
                                            .foregroundColor(fieldBorderGreen)
                                            .underline()
                                    }
                                }
                            }
                            .font(.system(size: 13, weight: .medium))
                            .padding(.top, 6)
                            
                            // Footer Switch: Already have an account? Log In
                            HStack(spacing: 4) {
                                Text("Already have an account?")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button {
                                    AppTheme.triggerHaptic(style: .light)
                                    if let onNavigateToLogin = onNavigateToLogin {
                                        onNavigateToLogin()
                                    } else {
                                        dismiss()
                                    }
                                } label: {
                                    Text("Log In")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(fieldBorderGreen)
                                        .underline()
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 28)
                        }
                        .padding(.horizontal, 28)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showTermsSheet) {
            TermsAndPrivacyModalView()
        }
    }
    
    // MARK: - Subviews & Field Builders
    
    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .words
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
            .textInputAutocapitalization(autocapitalization)
            .disableAutocorrection(true)
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
        .background(fieldDarkBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(fieldBorderGreen, lineWidth: 1.5)
        )
    }
    
    private func secureInputField(
        icon: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(fieldBorderGreen)
                .frame(width: 20)
            
            SecureField(
                "",
                text: text,
                prompt: Text(placeholder).foregroundColor(Color.white.opacity(0.5))
            )
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
        .background(fieldDarkBackground)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(fieldBorderGreen, lineWidth: 1.5)
        )
    }
    
    // MARK: - Actions
    
    private func handleSignUpAction() {
        // Password mismatch check
        if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
            alertTitle = "Passwords Do Not Match"
            alertMessage = "Please ensure both password fields match before proceeding."
            showAlert = true
            AppTheme.triggerNotificationHaptic(type: .error)
            return
        }
        
        isSubmitting = true
        AppTheme.triggerNotificationHaptic(type: .success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let activeName = fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "New Trader" : fullName
            let activeUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "new_trader" : username
            let activeEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "trader@xchange.app" : email
            
            userStore.currentUser.displayName = activeName
            userStore.currentUser.username = activeUsername
            userStore.currentUser.email = activeEmail
            userStore.saveCurrentUser()
            
            isSubmitting = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                isLoggedIn = true
            }
        }
    }
}

// MARK: - Terms & Privacy Sheet Modal

private struct TermsAndPrivacyModalView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Xchange Terms & Conditions")
                        .font(.title2.bold())
                    
                    Text("Welcome to Xchange, the peer-to-peer cashless barter platform. By creating an account, you agree to exchange items respectfully and use verified Safe Exchange Zones for physical transactions.")
                        .foregroundColor(.secondary)
                    
                    Text("1. Parity & Valuations")
                        .font(.headline)
                    Text("Valuation metrics provided by Xchange's Smart Appraisal AI are algorithmic estimates intended to guide mutual barter parity.")
                        .foregroundColor(.secondary)
                    
                    Text("2. Privacy & Safety")
                        .font(.headline)
                    Text("Your personal email and exact coordinates remain confidential until a barter trade is formally confirmed by both parties.")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Legal Terms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
    SignUpView(isLoggedIn: .constant(false))
        .environmentObject(UserStore())
}
