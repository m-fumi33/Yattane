import CoreData
import SwiftUI

struct MilestoneRow: View {
  let milestone: Milestone

  // Safely extract the first image data from the CoreData relationship
  var firstImageData: Data? {
    if let imagesSet = milestone.value(forKey: "images") as? NSSet,
      let images = imagesSet.allObjects as? [NSManagedObject]
    {
      // Sort by order if possible, otherwise just take the first
      let sorted = images.sorted {
        ($0.value(forKey: "order") as? Int16 ?? 0) < ($1.value(forKey: "order") as? Int16 ?? 0)
      }
      return sorted.first?.value(forKey: "imageData") as? Data
    }
    return nil
  }

  // Calculate age at the time of the milestone
  private var ageTag: String? {
    guard let child = milestone.child, let birthday = child.birthday, let date = milestone.date
    else { return nil }
    let components = Calendar.current.dateComponents([.month, .day], from: birthday, to: date)
    let month = components.month ?? 0
    let day = components.day ?? 0

    if month > 0 && day > 0 {
      return "\(month)ヶ月\(day)日"
    } else if month > 0 {
      return "\(month)ヶ月"
    } else if day >= 0 {
      return "\(day)日"
    }
    return nil
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Top Image Section
      ZStack(alignment: .topTrailing) {
        if let imageData = firstImageData, let uiImage = UIImage(data: imageData) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(height: 140)
            .clipShape(CustomCardCorner(radius: 24, corners: [.topLeft, .topRight]))
        } else {
          Rectangle()
            .fill(Color.theme.secondary.opacity(0.15))
            .frame(height: 80)
            .clipShape(CustomCardCorner(radius: 24, corners: [.topLeft, .topRight]))
            .overlay(
              Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundColor(Color.theme.secondary)
            )
        }

        // Age Overlay Tag
        if let age = ageTag {
          Text(age)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.theme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.theme.babyPink)
            .clipShape(Capsule())
            .padding(12)
        }
      }

      // Bottom Info Section
      VStack(alignment: .leading, spacing: 12) {
        // Date
        HStack(spacing: 6) {
          Image(systemName: "calendar")
            .foregroundColor(.theme.secondary)
          if let date = milestone.date {
            Text(date.formatted(date: .numeric, time: .omitted))
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundColor(.theme.textSecondary)
          }
        }

        // Title
        Text(milestone.title ?? "無題の記録")
          .font(.title3)
          .fontWeight(.bold)
          .foregroundColor(.theme.textPrimary)

        // Note / Comment Box
        if let note = milestone.note, !note.isEmpty {
          HStack(alignment: .top, spacing: 8) {
            Image(systemName: "wand.and.stars")
              .foregroundColor(.orange)
              .padding(.top, 2)
            Text(note)
              .font(.subheadline)
              .foregroundColor(.theme.textPrimary)
              .lineLimit(nil)
          }
          .padding(12)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.theme.babyYellow)
          .cornerRadius(12)
        }
      }
      .padding(16)
    }
    .background(Color.theme.cardBackground)
    .cornerRadius(24)
    .shadow(color: Color.theme.shadow, radius: 12, x: 0, y: 6)
  }
}

// Shape to round specific corners of a view
struct CustomCardCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect, byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
