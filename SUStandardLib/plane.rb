module SUStandardLib
module Geom

# Namespace for methods related to planes.
#
#   A plane can either be defined as an Array of a point and vector or as an
#   Array of 4 Floats defining the coefficients of the plane equation.
module Plane

  # Determine the unit normal vector for a plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Geom::Vector3d]
  def self.normal(plane)
    return plane[1].normalize if plane.size == 2
    a, b, c = plane

    ::Geom::Vector3d.new(a, b, c).normalize
  end

  # Check whether two planes are plane parallel.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Boolean]
  def self.parallel?(plane_a, plane_b)
    normal(plane_a).parallel?(normal(plane_b))
  end

  # Find arbitrary point on plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Geom::Point3d]
  def self.point(plane)
    return plane[0].normalize if plane.size == 2
    a, b, c, d = plane
    v = ::Geom::Vector3d.new(a, b, c)

    ORIGIN.offset(v, -d)
  end

  # Check whether two planes are the same.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Boolean]
  def self.same?(plane_a, plane_b)
    # REVIEW: Should true be returned for planes with opposite orientation?
    point(plane_a).on_plane?(plane_b) &&
      parallel?(plane_a, plane_b)
  end

  # Transform plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Geom::Transformation]
  # @return [Array(Geom::Point3d, Geom::Vector3d)]
  def self.transform_plane(plane, transformation)
    [
      point(plane).transform(transformation),
      Vector3d.transform_as_normal(normal(plane), transformation)
    ]
  end

end
end
end
