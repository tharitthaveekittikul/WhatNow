//
//  MallSelectionView.swift
//  WhatNow
//
//  Mall Selection View
//

import SwiftUI

struct MallSelectionView: View {
    @StateObject private var viewModel = MallSelectionViewModel()

    var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(.App.text)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("เกิดข้อผิดพลาด")
                        .font(.appTitle2)
                        .foregroundColor(.App.text)

                    Text(errorMessage)
                        .font(.appBody)
                        .foregroundColor(.App.textSecondary)
                        .multilineTextAlignment(.center)

                    Button("ลองอีกครั้ง") {
                        Task {
                            await viewModel.loadMalls()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.malls) { mall in
                            NavigationLink(destination: SpinView(mall: mall)) {
                                MallCardContent(mall: mall)
                            }
                            .buttonStyle(CardButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("เลือกห้าง")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.malls.isEmpty {
                await viewModel.loadMalls()
            }
        }
    }
}

struct MallCardContent: View {
    let mall: Mall

    var body: some View {
        HStack(spacing: 16) {
            Text("🏬")
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(mall.displayName)
                    .font(.appHeadline)
                    .foregroundColor(.App.text)

                Text(mall.city)
                    .font(.appCallout)
                    .foregroundColor(.App.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.App.textTertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.App.surface)
        )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appHeadline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.App.text)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    NavigationStack {
        MallSelectionView()
    }
}
