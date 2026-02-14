import SwiftUI

struct MilestoneRow: View {
  let milestone: Milestone

  var body: some View {
    HStack(spacing: 16) {
      if let data = milestone.photoData, let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .shadow(radius: 2)
      } else {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.gray.opacity(0.2))
          .frame(width: 60, height: 60)
          .overlay(
            Image(systemName: "photo")
              .foregroundColor(.gray)
          )
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(milestone.title ?? "タイトルなし")
          .font(.headline)
          .foregroundColor(.primary)

        if let date = milestone.date {
          VStack(alignment: .leading, spacing: 2) {
            Text(date, format: .dateTime.year().month().day().locale(Locale(identifier: "ja_JP")))
              .font(.subheadline)
              .foregroundColor(.secondary)

            if let age = ageString {
              Text(age)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 2)
            }
          }
        }
      }

      Spacer()
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
  }

  private var ageString: String? {
    guard let date = milestone.date,
      let birthday = milestone.child?.birthday
    else { return nil }

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: birthday, to: date)

    if let year = components.year, let month = components.month {
      if year > 0 {
        return "\(year)歳\(month)ヶ月"
      } else {
        return "\(month)ヶ月"
      }
    }
    return nil
  }
}
