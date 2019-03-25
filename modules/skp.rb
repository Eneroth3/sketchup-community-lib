module SkippyLib

# Namespace for methods related to SketchUp files.
module SKP

  # Get globally unique identifier (GUID) of external file.
  #
  # GUIDs are SketchUp's way of knowing if two component definitions are
  # identical. Each time a component definition is modified, the GUID is
  # regenerated.
  #
  # @param path [String]
  #
  # @return [String]
  def self.guid(path)
    # HACK: This is not official API. However it's not very likely to change
    # either, given how it's placed in the file header, and supposed to be
    # read by Sketchup without parsing the full file.
    guid = File.open(path, "rb") do |file|
      # SKP File Header Structure:
      #
      # "SketchUp Model" ID block (Fixed 32 bytes)
      # File version block (Variable bytes)
      # GUID (Fixed 16 bytes)
      #
      # Each block starts with FF FE FF followed by the block name size.

      # First skip over the .skp ID block and fetch the size of the version
      # info.
      file.seek(32 + 3)
      version_wchar_size = file.read(1).unpack("C").first
      version_byte_size = version_wchar_size * 2

      # Skip the version info.
      file.seek(version_byte_size, IO::SEEK_CUR)

      # Read the raw GUID bytes.
      #
      # struct Guid {
      #   unsigned int data1;
      #   unsigned short data2;
      #   unsigned short data3;
      #   unsigned char data4[8];
      # }
      file.read(16)
    end

    # Format consistently with Ruby API return value.
    data1, data2, data3, *data4 = guid.unpack("ISSC8")

    format("%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x",
           data1, data2, data3, *data4)
  end

  # Check if file is a SketchUp model.
  #
  # @param path [String]
  #
  # @return [Boolean]
  def self.valid?(path)
    prefix = "\xFF\xFE\xFF\x0ES\x00k\x00e\x00t\x00c\x00h\x00U\x00p\x00 \x00M\x00o\x00d\x00e\x00l"
    prefix.force_encoding("BINARY")

    File.binread(path, 64).start_with?(prefix)
  end

  # Get SketchUp version string of a saved file.
  #
  # @param path [String]
  #
  # @raise [IOError]
  #
  # @return [String]
  def self.version(path)
    v = File.binread(path, 64).tr("\x00", "")[/{([\d.]+)}/n, 1]

    v || raise(IOError, "Can't determine SU version for '#{path}'. Is file a model?")
  end

end
end
