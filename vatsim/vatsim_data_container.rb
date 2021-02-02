class VatsimDataContainer

  # Change string to "unknown" if invalid, for discord Embed requirements
  def clean_str_for_discord(x)
    if x.nil?
      return "unknown"
    end
    x = x.to_s
    if x.strip.empty?
      "unknown"
    else
      x
    end
  end
end