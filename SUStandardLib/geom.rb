module ExampleExtensionModule
module SUStandardLib
module Geom

  # TODO: Move arbitrary_non_parallel_vector and arbitrary_perpendicular_vector to Vector3d module.

  # Find an arbitrary unit vector that is not parallel to given vector.
  #
  # @param [Geom::Vector3d]
  # @return [Geom::Vector3d]
  def self.arbitrary_non_parallel_vector(vector)
    vector.parallel?(Z_AXIS) ? X_AXIS : Z_AXIS
  end

  # Find an arbitrary unit vector that is perpendicular to given vector.
  #
  # @param [Geom::Vector3d]
  # @return [Geom::Vector3d]
  def self.arbitrary_perpendicular_vector(vector)
    (vector * arbitrary_non_parallel_vector(vector)).normalize
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
