module ExampleExtensionModule
module SUStandardLib
module Vector3d

  # Transform vector as a normal, i.e. transform the plane it is perpendicular
  # to and return the plane's new normal. For non-uniform Transformations
  # this result differs from directly transforming the vector.
  #
  # @param [Geom::Vector3d)]
  # @param [Geom::Transformation]
  # @return [Geom::Vector3d]
  def self.transform_as_normal(normal, transformation)
    tangent = Geom.arbitrary_perpendicular_vector(normal)
    bi_tangent = normal * tangent

    tangent.transform!(transformation)
    bi_tangent.transform!(transformation)

    (tangent * bi_tangent).normalize# TODO: Reverse vector if Transformation is flipped.
  end

end
end
end
