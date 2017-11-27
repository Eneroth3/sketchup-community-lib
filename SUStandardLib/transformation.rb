module ExampleExtensionModule
module SUStandardLib
module Transformation

  # Compute the area scale factor of transformation at specific plane.
  #
  # @param [Geom::Transformation]
  # @param [Array(Geom::Point3d, Geom::Vector3d), Array(Float, Float, Float, Float)]
  # @return [Float]
  def self.scale_factor_in_plane(transformation, plane)
    normal = Geom.plane_normal(plane)
    tangent = Geom.arbitrary_perpendicular_vector(normal)
    bi_tangent = tangent * normal

    tangent.transform!(transformation)
    bi_tangent.transform!(transformation)

    (tangent * bi_tangent).length.to_f
  end

end
end
end
