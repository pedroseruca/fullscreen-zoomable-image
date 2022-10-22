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
            ZoomableImage {
                Image("iphones")
            }
        }
    }
}

struct ZoomableImage_Previews: PreviewProvider {
    static var previews: some View {
        ZoomableImage {
            Image("iphones")
        }
        .ignoresSafeArea()
    }
}
