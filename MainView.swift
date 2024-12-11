//
//  MainView.swift
//  DolarAlDia
//
//  Created by Carlos Vicente Pinto on 12/8/24.
//

import SwiftUI

struct MainView: View {
    @State private var showMenu = false

    var body: some View {
        ZStack {
            // Tu vista actual de "Dólar Al Día"
            NavigationView {
                DolarAlDiaView()
                    .navigationBarTitle("Dólar Al Día", displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        withAnimation {
                            self.showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    })
            }

            // Menú de hamburguesa
            if showMenu {
                HamburgerMenu(showMenu: $showMenu)
                    .transition(.move(edge: .leading))
            }
        }
    }
}

