# NavigationLinkConfusion

In summary: when a NavigationView contains a view whose data dependency is refreshed to a copy of the original value, on iOS 14 the navigation stack is unaffected, while on iOS 15 the navigation stack is popped to root.


Consider the following model and view:

````
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
````

When the Refresh button on the DetailView is tapped, the model in the root ContentView refreshes its own `Plan` object with an exact copy of the object. On iOS 14 and Xcode 12.5, this would cause nothing to happen - the identity of the `Plan` object was unchanged, so the navigation stack is unchanged. However, on iOS 15 and Xcode 13, this causes the navigation stack to pop to root.

![Recording](https://github.com/UberJason/NavigationLinkConfusion/blob/main/Recording.gif)