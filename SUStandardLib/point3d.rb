module SUStandardLib
module Geom

# Namespace for methods related to SketchUp's native Geom::Point3d class.
module Point3d

  # Check whether point lies between two other points.
  #
  # @param point [::Geom::Point3d]
  # @param boundary_a [::Geom::Point3d]
  # @param boundary_b [::Geom::Point3d]
  # @param include_boundaries [Boolean]
  #
  # @example
  #   SUStandardLib::Geom::Point3d.between?(ORIGIN, Geom::Point3d.new(0, -1, -1), Geom::Point3d.new(0, 1, 1))
  #   # => true
  #
  # @return [Boolean]
  def self.between?(point, boundary_a, boundary_b, include_boundaries = true)
    return false unless point.on_line?([boundary_a, boundary_b])
    vector_a = point - boundary_a
    vector_b = point - boundary_b
    return include_boundaries if !vector_a.valid? || !vector_a.valid?

    !vector_a.samedirection?(vector_b)
  end

  # Check whether point is in front of or behind a plane.
  #
  # @param point [::Geom::Point3d]
  # @param plane [Array(::Geom::Point3d, ::Geom::Vector3d), Array(Float, Float, Float, Float)]
  #
  # @return [Boolean]
  #   +true+ when in front, +false+ when behind or on plane.
  def self.front_of_plane?(point, plane)
    (point - point.project_to_plane(plane)) % Plane.normal(plane) > 0
  end

end
end
end
