module ExampleExtensionModule::SUStandardLib::Geom

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

    Geom::Vector3d.new(a, b, c).normalize
  end

  # Find arbitrary point on plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Geom::Point3d]
  def self.plane_point(plane)
    return plane[0].normalize if plane.size == 2
    a, b, c, d = plane
    v = Geom::Vector3d.new(a, b, c)

    ORIGIN.offset(v, -d)
  end

  # Compute the area scale factor of transformation at specific plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Geom::Transformation]
  # @return [Float]
  def self.scale_factor_in_plane(plane, transformation)
    normal = plane_normal(plane)
    tangent = arbitrary_perpendicular_vector(normal)
    bi_tangent = tangent * normal

    tangent.trasnform!(transformation)
    bi_tangent.trasnform!(transformation)

    (tangent * bi_tangent).length.to_f
  end

  # Transform plane.
  #
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @param [Geom::Transformation]
  # @return [Array(Geom::Point3d, Geom::Vector3d)]
  def self.transform_plane(plane, transformation)
    [
      plane_point(plane).transform(transformation),
      transform_vector_as_normal(plane_normal(plane))
    ]
  end

  # Transform vector as a normal, i.e. transform the plane it is perpendicular
  # to and return the plane's new normal. For non-uniform Transformations
  # this result differs from directly transforming the vector.
  #
  # @param [Geom::Vector3d)]
  # @param [Geom::Transformation]
  # @return [Geom::Vector3d]
  def self.transform_vector_as_normal(normal, transformation)
    tangent = arbitrary_perpendicular_vector(normal)
    bi_tangent = normal * tangent

    tangent.transform!(transformation)
    bi_tangent.transform!(transformation)

    (tangent * bi_tangent).normalize# TODO: Reverse vector if Transformation is flipped.
  end

end
