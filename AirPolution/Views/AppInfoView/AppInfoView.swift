//

import SwiftUI

struct AppInfoView: View {
  let moods: [Mood] = [.good, .moderate, .bad, .unhealthy, .hazardous]
  
  var body: some View {
    ZStack {
      Color.backgroundColor
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        
        HStack(spacing: 0) {
          Text("Air Pol")
          Text("l")
            .foregroundColor(.red)
          Text("ution")
        }
        .font(.title.weight(.bold))
        .padding(.top, 5)
        .padding(.bottom, 1)
        Text("© 2023 Stefan B. Kozhuharov")
          .font(.caption2)
        Text("Realtime air pollution levels")
          .padding(.top, 5)
          .font(.headline)
        VStack(spacing: 0) {
          Image("WorldMap")
            .resizable()
            .aspectRatio(2, contentMode: .fit)
            .frame(maxHeight: 170)
          TextJustified("AppInfo")
            .frame(maxHeight: 270)
          HStack(spacing: 0) {
            Group {
              ForEach(moods, id: \.self) { mood in
                MoodIconText(mood: mood)
              }
            }
          }
          .frame(height: 40)
          .padding(.top, 10)
          .padding(.bottom, 15)
          .padding(.horizontal, -13)
          Spacer()
        }
        .frame(maxWidth: 400, maxHeight: 600)
        .padding(.horizontal, 13)
      }
      .padding(.horizontal, 2)
    }
  }
  
}

struct TextJustified: UIViewRepresentable {
  private let file: String
  init(_ file: String) {
    self.file = file
  }
  
  func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    let appinfoPath = Bundle.main.url(forResource: file, withExtension: "rtf")!
    let attributedString = try! NSMutableAttributedString(url: appinfoPath,
                                                          documentAttributes: nil)
    textView.attributedText = attributedString
    textView.isUserInteractionEnabled = true
    textView.isEditable = false
    textView.textAlignment = .justified
    textView.textColor = UIColor(named: "TextColor")
    textView.font = UIFont(name: "Helvetica", size: 15)!
    textView.sizeToFit()
    textView.backgroundColor = UIColor(.backgroundColor)
    return textView
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
  }
}

struct AppInfoView_Previews: PreviewProvider {
  static var previews: some View {
    AppInfoView()
  }
}
