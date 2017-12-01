module SUStandardLib
module Geom

  # Determine the unit normal vector for a plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Geom::Vector3d]
  def self.plane_normal(plane)
    return plane[1].normalize if plane.size == 2
    a, b, c = plane

    ::Geom::Vector3d.new(a, b, c).normalize
  end

  # Check whether two planes are plane parallel.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Boolean]
  def self.plane_parallel?(plane_a, plane_b)
    plane_normal(plane_a).parallel?(plane_normal(plane_b))
  end

  # Find arbitrary point on plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Geom::Point3d]
  def self.plane_point(plane)
    return plane[0].normalize if plane.size == 2
    a, b, c, d = plane
    v = ::Geom::Vector3d.new(a, b, c)

    ORIGIN.offset(v, -d)
  end

  # Compute area of an array of points representing a polygon.
  #
  # @param [Array<Geom::Point3d>]
  # @return [Float]
  def self.polygon_area(points)
    origin = points.first
    normal = polygon_normal(points)

    area = 0
    points.each_with_index do |pt0, i|
      pt1 = points[i + 1] || points.first
      triangle_area = ((pt1 - pt0) * (origin - pt0)).length / 2
      if (pt1 - pt0) * (origin - pt0) % normal > 0
        area += triangle_area
      else
        area -= triangle_area
      end
    end

    area
  end

  # Find normal vector from an array of points representing a polygon.
  #
  # @param [Array<Geom::Point3d>]
  #
  # @example Find normal of a face
  #   # Select a face and run:
  #   face = Sketchup.active_model.selection.first
  #   points = face.vertices.map(&:position)
  #   normal = SUStandardLib::Geom.polygon_normal(points)
  #
  # @return [Geom::Vector3d]
  def self.polygon_normal(points)
    normal = ::Geom::Vector3d.new
    points.each_with_index do |pt0, i|
      pt1 = points[i + 1] || points.first
      normal.x += (pt0.y - pt1.y) * (pt0.z + pt1.z)
      normal.y += (pt0.z - pt1.z) * (pt0.x + pt1.x)
      normal.z += (pt0.x - pt1.x) * (pt0.y + pt1.y)
    end

    normal.normalize
  end

  # Check whether two planes are the same.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Boolean]
  def self.same_plane?(plane_a, plane_b)
    # REVIEW: Should true be returned for planes with opposite orientation?
    plane_point(plane_a).on_plane?(plane_b) &&
      plane_parallel?(plane_a, plane_b)
  end

  # Transform plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Geom::Transformation]
  # @return [Array(Geom::Point3d, Geom::Vector3d)]
  def self.transform_plane(plane, transformation)
    [
      plane_point(plane).transform(transformation),
      Vector3d.transform_as_normal(plane_normal(plane), transformation)
    ]
  end

end
end
