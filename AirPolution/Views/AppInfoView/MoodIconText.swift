//

import SwiftUI

struct MoodIconText: View {
  let mood: Mood
  
    var body: some View {
        VStack {
          Image("\(mood.rawValue)-note")
            .resizable()
            .aspectRatio(contentMode: .fill)
          Text(mood.rawValue.capitalized)
            .font(.caption2)
            .foregroundColor(mood.colorText)
        }
    }
}

struct MoodIconText_Previews: PreviewProvider {
    static var previews: some View {
      MoodIconText(mood:.moderate)
    }
}
