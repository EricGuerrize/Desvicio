enum ShieldCopy {
    static func make(name: String, mood: Int, focusing: Bool) -> (title: String, subtitle: String) {
        if focusing {
            return ("Pausa para o \(name)", "Os apps escolhidos ficam bloqueados pra oxigenar a cabeça.")
        }
        switch mood {
        case 1: return ("\(name) está cansado", "O excesso de tela começou a pesar. Que tal uma pausa?")
        case 2: return ("\(name) está fritando", "Chega de scroll infinito por agora!")
        case 3: return ("\(name) pifou!", "Limite diário atingido. Apps bloqueados pra salvar sua cabeça.")
        default: return ("\(name) está saudável", "Tá sobrando tempo pra viver lá fora.")
        }
    }
}

#if SHIELD_COPY_CHECK
@main
struct ShieldCopyCheck {
    static func main() {
        let focus = ShieldCopy.make(name: "Meu Cérebro", mood: 0, focusing: true)
        assert(focus.title == "Pausa para o Meu Cérebro")
        assert(focus.subtitle == "Os apps escolhidos ficam bloqueados pra oxigenar a cabeça.")
        let ghost = ShieldCopy.make(name: "Meu Cérebro", mood: 3, focusing: false)
        assert(ghost.title == "Meu Cérebro pifou!")
        assert(ghost.subtitle == "Limite diário atingido. Apps bloqueados pra salvar sua cabeça.")
        let both = ShieldCopy.make(name: "Meu Cérebro", mood: 3, focusing: true)
        assert(both.title == "Pausa para o Meu Cérebro")
    }
}
#endif
