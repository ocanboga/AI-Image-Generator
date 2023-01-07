//
//  ContentView.swift
//  AI-Image-Generator
//
//  Created by osman canboga on 7.01.2023.
//
import OpenAIKit
import SwiftUI

final class ViewModel: ObservableObject{
    private var openai: OpenAI?
    func setup(){
        openai = OpenAI(Configuration(organization: "Personal", apiKey: "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"))
    }
    
    func generateImage(prompt: String) async -> UIImage?{
        guard let openai = openai else{
            return nil
        }
        
        do{
           let params = ImageParameters(
            prompt: prompt,
            resolution: .medium,
            responseFormat: .base64Json
           )
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        }
        catch{
            print(String(describing: error))
            return nil
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image : UIImage?
    
    var body: some View {
        NavigationView {
            VStack{
                if let image = image{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        .frame(width: 500,height: 500)
                }
                else
                {
                    Text("Type prompt to generate image!")
                }
                Spacer()
                
                TextField("Type prompt here..", text:$text)
                    .padding()
                Button("Generate!"){
                    Task{
                        if !text.trimmingCharacters(in: .whitespaces).isEmpty{
                            let result = await viewModel.generateImage(prompt: text)
                            if result == nil{
                                print("Failed to get image")
                            }
                            self.image = result
                        }
                        
                    }
                }
                
            }
            .navigationTitle("DALL-E Image Generator")
            .onAppear{
                viewModel.setup()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
