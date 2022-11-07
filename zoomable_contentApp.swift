//
//  zoomable_contentApp.swift
//  zoomable-content
//
//  Created by Pedro Seruca on 22/10/2022.
//

import SwiftUI

@main
struct zoomable_contentApp: App {
    var body: some Scene {
        WindowGroup {
            ZoomableContent(isVisible: .constant(true)) {
                Image("iphones")
                    .resizable()
            }
            .ignoresSafeArea()
        }
    }
}

struct ZoomableImage_Previews: PreviewProvider {
    static var previews: some View {
        ZoomableContent(isVisible: .constant(true)) {
            Image("iphones")
                .resizable()
        }
        .ignoresSafeArea()
        
        ZoomableContent(isVisible: .constant(true)) {
            ZStack {
                Rectangle()
                    .fill(Color.red.gradient)
                Text("Content test")
            }
        }
        .ignoresSafeArea()
        .previewDisplayName("with Content")
    }
}
