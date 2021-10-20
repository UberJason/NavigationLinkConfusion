//
//  ContentView.swift
//  NavigationLinkConfusion
//
//  Created by Jason Ji on 10/20/21.
//

import Combine
import SwiftUI

struct Plan: Identifiable {
    let id = UUID()
    let title: String
    let detail: Detail
}

struct Detail: Identifiable {
    let id = UUID()
    let title: String
}

class Model: ObservableObject {
    @Published var plans = [Plan]()
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        refreshPlans()
        
        NotificationCenter.default.publisher(for: .refresh)
            .sink { [unowned self] _ in
                self.refreshPlans()
            }
            .store(in: &cancellables)
    }
    
    func refreshPlans() {
        plans = [
            Plan(title: "Plan 1", detail: Detail(title: "Detail 1"))
        ]
    }
}

struct ContentView: View {
    @StateObject var model = Model()
    
    var body: some View {
        NavigationView {
            List(model.plans) { plan in
                NavigationLink(destination:
                    DetailView(title: plan.detail.title)
                , label: {
                    Text(plan.title)
                })
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Notification.Name {
    static let refresh = Notification.Name(rawValue: "refresh")
}

struct DetailView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
            Button("Refresh") {
                NotificationCenter.default.post(name: .refresh, object: nil)
            }
        }
    }
}
