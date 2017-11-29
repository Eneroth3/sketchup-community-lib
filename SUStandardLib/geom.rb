module ExampleExtensionModule
module SUStandardLib
module Geom

  # Check whether two planes are the same.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @returns [Boolean]
  def self.same_plane?(plane_a, plane_b)
    # REVIEW: Should true be returned for planes with opposite orientation?
    plane_point(plane_a).on_plane?(plane_b) &&
    plane_parallel?(plane_a, plane_b)
  end

  # Determine the unit normal vector for a plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Geom::Vector3d]
  def self.plane_normal(plane)
    return plane[1].normalize if plane.size == 2
    a, b, c, _ = plane

    ::Geom::Vector3d.new(a, b, c).normalize
  end

  # Check whether two planes are plane parallel.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @returns [Boolean]
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
end
