# Structure for representing an Extron Simple Instruction Set  command that can
# transmitted to a device.
#
# Commands are composed from a set of *fields*. The contents and types of these
# are arbitrary, however they must be capable of serialising to an IO.
#
# Utility methods are provided to form well definied commands. This should be
# stongly prefered over constructing raw `Command` instances as they provide
# improved type safety as well as run-time checks for paramter bounds where
# applicable.
struct Extron::SIS::Command(*T)
  def initialize(*fields : *T)
    @fields = fields
  end

  getter fields : T

  # Serialises `self` in a format suitable for log messages.
  def to_s(io : IO)
    io << '‹'
    to_io io
    io << '›'
  end

  # Writes `self` to the passed *io*.
  def to_io(io : IO, format = IO::ByteFormat::SystemEndian)
    fields.each do |field|
      io << field
    end
  end

  # Syntactical suger for `Command` definition. Provides the ability to express
  # command fields in the same way as `Byte` objects and other similar
  # collections from the Crystal std lib.
  macro [](*fields)
    Extron::SIS::Command.new {{*fields}}
  end

  private macro enforce(predicate, message)
    raise ArgumentError.new {{message}} unless {{predicate}}
  end

  # Ties *input* to *output* at the specified *layer*.
  def self.tie(input : Int, output : Int, layer = SwitchLayer::All)
    enforce input > 0, "input must be positive"
    enforce output > 0, "output must be positive"
    Command[input, '*', output, layer]
  end

  # Ties *input* to all outputs.
  def self.tie(input : Int, layer : SwitchLayer)
    enforce input > 0, "input must be positive"
    Command[input, '*', layer]
  end

  # Disconnect signal to all outputs.
  def self.untie_outputs
    Command[0, '*', 0, SwitchLayer::All]
  end

  # Disconnect signal to *output*.
  def self.untie_output(output : Int)
    enforce output > 0, "output must be positive"
    Command[0, '*', output, SwitchLayer::All]
  end

  # Disconnect a signal *input* from all outputs.
  def self.untie_input(input : Int)
    enforce input > 0, "input must be positive"
    Command[input, '*', 0, SwitchLayer::All]
  end
end