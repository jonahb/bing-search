module BingSearch
  module Adult
    Off = 'Off'
    Moderate = 'Moderate'
    Strict = 'Strict'
  end

  module FileType
    DOC = 'DOC'
    DWF = 'DWF'
    FEED = 'FEED'
    HTM = 'HTM'
    HTML = 'HTML'
    PDF = 'PDF'
    PPT = 'PPT'
    RTF = 'RTF'
    TEXT = 'TEXT'
    TXT = 'TXT'
    XLS = 'XLS'
  end

  module ImageFilter
    Small = 'Size:Small'
    Medium = 'Size:Medium'
    Large = 'Size:Large'
    Square = 'Aspect:Square'
    Wide = 'Aspect:Wide'
    Tall = 'Aspect:Tall'
    Color = 'Color:Color'
    Monochrome = 'Color:Monochrome'
    Photo = 'Style:Photo'
    Graphics = 'Style:Graphics'
    Face = 'Face:Face'
    Portrait = 'Face:Portrait'
    OtherFace = 'Face:Other'
  end

  module NewsCategory
    Business = 'rt_Business'
    Entertainment = 'rt_Entertainment'
    Health = 'rt_Health'
    Politics = 'rt_Politics'
    Sports = 'rt_Sports'
    US = 'rt_US'
    World = 'rt_World'
    ScienceAndTechnology = 'rt_ScienceAndTechnology'
  end

  module NewsSort
    Date = 'Date'
    Relevance = 'Relevance'
  end

  module Source
    Web = 'Web'
    Image = 'Image'
    Video = 'Video'
    News = 'News'
    SpellingSuggestions = 'Spell'
    RelatedSearch = 'RelatedSearch'
  end

  module VideoFilter
    Short = 'Duration:Short'
    Medium = 'Duration:Medium'
    Long = 'Duration:Long'
    StandardAspect = 'Aspect:Standard'
    Widescreen = 'Aspect:Widescreen'
    LowResolution = 'Resolution:Low'
    MediumResolution = 'Resolution:Medium'
    HighResolution = 'Resolution:High'
  end

  module VideoSort
    Date = 'Date'
    Relevance = 'Relevance'
  end
end
