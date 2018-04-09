class Ohlson
    def initialize(grill, korv)
        p "idag ska vi grilla " + korv
        p "men även också " + grill
    end
end

class Karlsson < Ohlson
    def initialize(salami, grill, korv, klass)
        @ohl = klass.new(salami, grill)
    end

    def kalas
        p "hemligt kalas"
    end

    def pub_kalas
        p "allmänt kalas"
        kalas
    end

end

a = Karlsson.new("visteti", "honung", "körv", Ohlson)
a.pub_kalas
