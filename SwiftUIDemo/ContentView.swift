//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Rahul Patel on 10/06/19.
//  Copyright © 2019 Rahul Patel. All rights reserved.
//

import SwiftUI
import Combine

//MARK:- Response model
struct UserResponseModel: Codable {
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    let data: [User]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case perPage = "per_page"
        case total = "total"
        case totalPages = "total_pages"
        case data = "data"
    }
}

struct User: Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email = "email"
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar = "avatar"
    }
}

//MARK:- Network manager
class NetworkManager: BindableObject {
    var didChange = PassthroughSubject<NetworkManager, Never>()
    
    var users = [User]() {
        didSet {
            didChange.send(self)
        }
    }
    
    init() {
        guard let url = URL(string: "https://reqres.in/api/users?page=2") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _ , _ ) in
            guard let data = data else { return }
            
            let response = try? JSONDecoder().decode(UserResponseModel.self, from: data)
            if let response = response {
                DispatchQueue.main.async {
                    self.users = response.data
                }
            }
        }.resume()
        
    }
}

//MARK:- Content view and image view with image loader
struct ContentView : View {
    
    @State var networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            List (networkManager.users.identified(by: \.firstName)) { user in
                ImageviewWidget(imageURl: user.avatar)
                Text(user.firstName)
            }.navigationBarTitle(Text("JSON Demo"))
        }
    }
}

class ImageLoader: BindableObject {
    var didChange = PassthroughSubject<Data, Never>()
    
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _ , _ ) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }.resume()
    }
}

struct ImageviewWidget : View {
    
    @ObjectBinding var imageLoader: ImageLoader
    
    init (imageURl: String) {
        imageLoader = ImageLoader(imageURL: imageURl)
    }
    
    var body: some View {
        Image(uiImage: (imageLoader.data.count == 0 ) ? UIImage(named: "placeholder")! : UIImage(data: imageLoader.data)!)
        .resizable()
        .frame(width: 50, height: 50)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
        .shadow(radius: 10)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
