
extension Array<Record> {
  mutating func clearOldTimestamps() {
    let uniquePosts = Array(Set<Record>(self))
    self.removeAll()
    self.append(contentsOf: uniquePosts)
  }
  
  mutating func mergeSensors() -> Array<Record> {
    self.indices.forEach {
      if self[$0].locationId != -111 {
        let record = self[$0]
        if let index = self.lastIndex(where: { $0.locationId == record.locationId }), index != $0 {
          self[$0].sensordatavalues.append(contentsOf: self[index].sensordatavalues)
          self[index].locationId = -111
        }
      }
    }
    return self.filter { $0.locationId != -111}
  }
  
}
