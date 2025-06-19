//
//  McDonald_sApp.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import SwiftUI

@main
struct McDonaldsApp: App {
    @StateObject var calendarViewModel = WorkCalendarViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    UploadView(calendarViewModel: calendarViewModel)
                }
                .tabItem {
                    Label("업로드", systemImage: "square.and.arrow.up")
                }

                NavigationView {
                    WorkCalendarView(viewModel:     calendarViewModel)
                }
                .tabItem {
                    Label("급여 달력", systemImage: "calendar")
                }
            }
            .preferredColorScheme(.light)
        }
    }
}

