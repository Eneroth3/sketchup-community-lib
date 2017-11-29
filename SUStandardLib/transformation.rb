module ExampleExtensionModule
module SUStandardLib
module Transformation

  # Check whether two transformations are the same using SketchUp's internal
  # precision for Point3d and Vector3d comparison.
  #
  # @param [Geom::Transformation]
  # @param [Geom::Transformation]
  # @return [Boolean]
  def self.same(transformation_a, transformation_b)
    xaxis(transformation_a) == xaxis(transformation_b) &&
    yaxis(transformation_a) == yaxis(transformation_b) &&
    zaxis(transformation_a) == zaxis(transformation_b) &&
    transformation_a.origin == transformation_b.origin
  end

  # Calculate determinant of 3X3 matrix.
  #
  # @param [Geom::Transformation]
  # @return [Float]
  def self.determinant(transformation)
    xaxis(transformation) % (yaxis(transformation) * zaxis(transformation))
  end

  # Check whether transformation is flipped (mirrored).
  #
  # @param [Geom::Transformation]
  # @return [Boolean]
  def self.flipped?(transformation)
    determinant(transformation) < 0
  end

  # Check whether a transformation is the identity transformation.
  #
  # @param [Geom::Transformation]
  # @return [Boolean]
  def self.identity?(transformation)
    compare(transformation, IDENTITY)
  end

  # Compute the area scale factor of transformation at specific plane.
  #
  # @param [Geom::Transformation]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Float]
  def self.scale_factor_in_plane(transformation, plane)
    normal = Geom.plane_normal(plane)
    tangent = Vector.arbitrary_perpendicular_vector(normal)
    bi_tangent = tangent * normal

    tangent.transform!(transformation)
    bi_tangent.transform!(transformation)

    (tangent * bi_tangent).length.to_f
  end

  # Check whether transformation is skewed (not orthogonal).
  #
  # @param [Geom::Transformation]
  # @return [Boolean]
  def self.skewed?(transformation)
    !xaxis(transformation).parallel?(yaxis(transformation) * zaxis(transformation))
  end

  # Get the X axis vector of a transformation. Unlike native
  # Transformation#xaxis this method returns a vector which length resembles
  # scaling instead of a unit vector.
  #
  # @param [Geom::Transformation]
  # @return [Geom::Vector3d]
  def self.xaxis(transformation)
    ::Geom::Vector3d.new(transformation.to_a.values_at(0..2))
  end

  # Get the Y axis vector of a transformation. Unlike native
  # Transformation#yaxis this method returns a vector which length resembles
  # scaling instead of a unit vector.
  #
  # @param [Geom::Transformation]
  # @return [Geom::Vector3d]
  def self.yaxis(transformation)
    ::Geom::Vector3d.new(transformation.to_a.values_at(4..6))
  end

  # Get the Z axis vector of a transformation. Unlike native
  # Transformation#zaxis this method returns a vector which length resembles
  # scaling instead of a unit vector.
  #
  # @param [Geom::Transformation]
  # @return [Geom::Vector3d]
  def self.zaxis(transformation)
    ::Geom::Vector3d.new(transformation.to_a.values_at(8..10))
  end

end
end
end
