//
//  ErrorView.swift
//  FetchAppAssignment
//
//  Created by Brooklyn Gibbs on 2/3/25.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                retryAction()
            }
        }
        .padding()
    }
}
