module SUStandardLib
module Geom

# Namespace for methods related to SketchUp's native Geom::Transformation class.
module Transformation

  # Create transformation from origin point and axes vectors.
  #
  # Unlike native +Geom::Transformation.axes+ this method does not make the axes
  # orthogonal or normalize them but uses them as they are, allowing for scaled
  # and skewed transformations.
  #
  # @param origin [::Geom::Point3d]
  # @param xaxis [::Geom::Vector3d]
  # @param yaxis [::Geom::Vector3d]
  # @param zaxis [::Geom::Vector3d]
  #
  # @example
  #   # Skew selected group/component
  #   # Select a group or component and run:
  #   e = Sketchup.active_model.selection.first
  #   e.transformation = SUStandardLib::Geom::Transformation.create_from_axes(
  #     ORIGIN,
  #     Geom::Vector3d.new(2, 0.3, 0.3),
  #     Geom::Vector3d.new(0.3, 2, 0.3),
  #     Geom::Vector3d.new(0.3, 0.3, 2)
  #   )
  #
  # @raise [ArgumentError] if any of the provided axes are parallel.
  # @raise [ArgumentError] if any of the vectors are zero length.
  #
  # @return [::Geom::Transformation]
  def self.create_from_axes(origin, xaxis, yaxis, zaxis)
    unless [xaxis, yaxis, zaxis].all?(&:valid?)
      raise ArgumentError, "Axes must not be zero length."
    end
    if xaxis.parallel?(yaxis) || yaxis.parallel?(zaxis) || zaxis.parallel?(xaxis)
      raise ArgumentError, "Axes must not be parallel."
    end

    ::Geom::Transformation.new([
      xaxis.x,  xaxis.y,  xaxis.z,  0,
      yaxis.x,  yaxis.y,  yaxis.z,  0,
      zaxis.x,  zaxis.y,  zaxis.z,  0,
      origin.x, origin.y, origin.z, 1
    ])
  end

  # Calculate determinant of 3X3 matrix.
  #
  # @param transformation [::Geom::Transformation]
  #
  # @return [Float]
  def self.determinant(transformation)
    xaxis(transformation) % (yaxis(transformation) * zaxis(transformation))
  end

  # Check whether transformation is flipped (mirrored).
  #
  # @param transformation [::Geom::Transformation]
  #
  # @return [Boolean]
  def self.flipped?(transformation)
    determinant(transformation) < 0
  end

  # Check whether a transformation is the identity transformation.
  #
  # @param transformation [::Geom::Transformation]
  #
  # @return [Boolean]
  def self.identity?(transformation)
    same?(transformation, IDENTITY)
  end

  # Create non-scaling transformation based on a transformation.
  #
  # @param transformation [::Geom::Transformation]
  #
  # @example
  #   # Mimic Context Menu > Reset Scale
  #   # Select a skewed group or component and run:
  #   e = Sketchup.active_model.selection.first
  #   e.transformation = SUStandardLib::Geom::Transformation.reset_scale(
  #     SUStandardLib::Geom::Transformation.reset_skew(e.transformation, false)
  #   )
  #   # Note that native Reset Scale also resets skew, not just scale.
  #
  # @return [::Geom::Transformation]
  def self.reset_scale(transformation)
    # FIXME: Native reset scale behaves differently when Transformation is flipped.
    create_from_axes(
      transformation.origin,
      xaxis(transformation).normalize,
      yaxis(transformation).normalize,
      zaxis(transformation).normalize
    )
  end

  # Create a orthogonal transformation based on a transformation.
  #
  # @param transformation [::Geom::Transformation]
  # @param preserve_determinant_value [Boolean]
  #   If +true+ the determinant value of the transformation, and thus the volume
  #   of an object transformed with it, is preserved. If +false+ lengths along
  #   axes are preserved (the behavior of SketchUp's native Context Menu >
  #   Reset Skew).
  #
  # @example
  #   # Mimic Context Menu > Reset Skew
  #   # Select a skewed group or component and run:
  #   e = Sketchup.active_model.selection.first
  #   e.transformation = SUStandardLib::Geom::Transformation.reset_skew(e.transformation, false)
  #
  #   # Reset Skewing While Retaining Volume
  #   # Select a skewed group or component and run:
  #   e = Sketchup.active_model.selection.first
  #   e.transformation = SUStandardLib::Geom::Transformation.reset_skew(e.transformation, true)
  #
  # @return [::Geom::Transformation]
  def self.reset_skew(transformation, preserve_determinant_value = false)
    xaxis = xaxis(transformation)
    yaxis = yaxis(transformation)
    zaxis = zaxis(transformation)

    new_yaxis = xaxis.normalize * yaxis * xaxis.normalize
    new_zaxis = new_yaxis.normalize * (xaxis.normalize * zaxis * xaxis.normalize) * new_yaxis.normalize

    unless preserve_determinant_value
      new_yaxis.length = yaxis.length
      new_zaxis.length = zaxis.length
    end

    create_from_axes(
      transformation.origin,
      xaxis,
      new_yaxis,
      new_zaxis
    )
  end

  # Check whether two transformations are the same using SketchUp's internal
  # precision for Point3d and Vector3d comparison.
  #
  # @param transformation_a [::Geom::Transformation]
  # @param transformation_b [::Geom::Transformation]
  #
  # @return [Boolean]
  def self.same?(transformation_a, transformation_b)
    xaxis(transformation_a) == xaxis(transformation_b) &&
      yaxis(transformation_a) == yaxis(transformation_b) &&
      zaxis(transformation_a) == zaxis(transformation_b) &&
      transformation_a.origin == transformation_b.origin
  end

  # Compute the area scale factor of transformation at specific plane.
  #
  # @param transformation [::Geom::Transformation]
  # @param plane [Array(::Geom::Point3d, ::Geom::Vector3d), Array(Float, Float, Float, Float)]
  #
  # @return [Float]
  def self.scale_factor_in_plane(transformation, plane)
    normal = Plane.normal(plane)
    tangent = Vector.arbitrary_perpendicular_vector(normal)
    bi_tangent = tangent * normal

    tangent.transform!(transformation)
    bi_tangent.transform!(transformation)

    (tangent * bi_tangent).length.to_f
  end

  # Check whether transformation is skewed (not orthogonal).
  #
  # @param transformation [::Geom::Transformation]
  #
  # @return [Boolean]
  def self.skewed?(transformation)
    !xaxis(transformation).parallel?(yaxis(transformation) * zaxis(transformation))
  end

  # Get the X axis vector of a transformation. Unlike native
  # Transformation#xaxis this method returns a vector which length resembles
  # scaling instead of a unit vector.
  #
  # @param transformation [::Geom::Transformation]
  #
  # @return [::Geom::Vector3d]
  def self.xaxis(transformation)
    ::Geom::Vector3d.new(transformation.to_a.values_at(0..2))
  end

  # Get the Y axis vector of a transformation. Unlike native
  # Transformation#yaxis this method returns a vector which length resembles
  # scaling instead of a unit vector.
  #
  # @param transformation [::Geom::Transformation]
  #
  # @return [::Geom::Vector3d]
  def self.yaxis(transformation)
    ::Geom::Vector3d.new(transformation.to_a.values_at(4..6))
  end

  # Get the Z axis vector of a transformation. Unlike native
  # Transformation#zaxis this method returns a vector which length resembles
  # scaling instead of a unit vector.
  #
  # @param transformation [::Geom::Transformation]
  #
  # @return [::Geom::Vector3d]
  def self.zaxis(transformation)
    ::Geom::Vector3d.new(transformation.to_a.values_at(8..10))
  end

end
end
end
