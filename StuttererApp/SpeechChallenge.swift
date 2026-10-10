import SwiftUI

// difficulty tier for a speech sound challenge
enum ChallengeDifficulty: String, Codable, CaseIterable {
    case easy
    case intermediate
    case hard
    case veryHard

    // short label shown on the pill
    var label: String {
        switch self {
        case .easy: return "Easy"
        case .intermediate: return "Intermediate"
        case .hard: return "Hard"
        case .veryHard: return "Very Hard"
        }
    }

    // colour used for the difficulty pill
    var tint: Color {
        switch self {
        case .easy: return .green
        case .intermediate: return .yellow
        case .hard: return .orange
        case .veryHard: return .red
        }
    }
}

// a single speech technique
struct ChallengeTechnique {
    let title: String
    let difficulty: ChallengeDifficulty
    let hint: String
    let tip: String
}

// one challenge for a specific sound
struct SpeechChallenge: Identifiable {
    let id: String
    let index: Int
    let title: String
    let difficulty: ChallengeDifficulty
    let prompt: String
    let hint: String
    let techniqueTip: String
    let placementTip: String
    let patterns: [String]

    var targetWords: [String] {
        SpeechChallenge.targetWords(in: prompt, patterns: patterns)
    }

    // finds words containing the target sound
    static func targetWords(in prompt: String, patterns: [String]) -> [String] {
        let lowered = patterns.map { $0.lowercased() }

        return prompt
            .split { !$0.isLetter }
            .map { String($0) }
            .filter { word in
                let lowerWord = word.lowercased()
                return lowered.contains { lowerWord.contains($0) }
            }
    }
}

// a sound with its own practice prompts
struct SpeechSound: Identifiable {
    let id: String
    let symbol: String
    let name: String
    let placementTip: String
    let patterns: [String]
    let prompts: [String]

    // english sounds use the original techniques
    // spanish sounds use four adapted techniques
    var challenges: [SpeechChallenge] {

        let techniques = id.hasPrefix("ES-")
            ? SpeechCatalog.spanishTechniques
            : SpeechCatalog.techniques

        return zip(techniques.enumerated(), prompts).map { pair, prompt in
            let (offset, technique) = pair

            return SpeechChallenge(
                id: "\(id.lowercased())-\(offset + 1)",
                index: offset + 1,
                title: technique.title,
                difficulty: technique.difficulty,
                prompt: prompt,
                hint: technique.hint,
                techniqueTip: technique.tip,
                placementTip: placementTip,
                patterns: patterns
            )
        }
    }
}

// static content for the speech sound challenges feature
enum SpeechCatalog {

    // original english techniques
    static let techniques: [ChallengeTechnique] = [
        ChallengeTechnique(
            title: "Easy Onset",
            difficulty: .easy,
            hint: "Begin each word with a soft, breathy start before your voice comes in.",
            tip: "Ease gently into the first sound instead of pushing hard."
        ),
        ChallengeTechnique(
            title: "Light Contacts",
            difficulty: .easy,
            hint: "Touch your lips, tongue, and teeth lightly — keep every contact gentle.",
            tip: "Imagine the sounds are feather-light and relaxed."
        ),
        ChallengeTechnique(
            title: "Prolonged Speech",
            difficulty: .intermediate,
            hint: "Stretch the vowels and glide smoothly from one word into the next.",
            tip: "Slow down and let the words flow together like a gentle wave."
        ),
        ChallengeTechnique(
            title: "Pausing & Phrasing",
            difficulty: .intermediate,
            hint: "Pause at natural breaks and speak in small, easy phrases.",
            tip: "Take a calm breath at each pause before continuing."
        ),
        ChallengeTechnique(
            title: "Voluntary Stuttering",
            difficulty: .hard,
            hint: "Add a calm, controlled bounce on purpose to take away the fear.",
            tip: "Staying in control of an easy repetition builds confidence."
        ),
        ChallengeTechnique(
            title: "Phone Call Practice",
            difficulty: .hard,
            hint: "Imagine you are on a call — keep your pace steady and your breath easy.",
            tip: "Focus on your rhythm, not on how the listener reacts."
        ),
        ChallengeTechnique(
            title: "Spontaneous Monologue",
            difficulty: .veryHard,
            hint: "Read it like your own story — keep it easy and unhurried.",
            tip: "Let the words flow naturally and keep your speech relaxed."
        ),
        ChallengeTechnique(
            title: "Audience Simulation",
            difficulty: .veryHard,
            hint: "Picture a small audience and stay grounded in your rhythm.",
            tip: "Breathe, slow down, and trust the techniques you practiced."
        )
    ]

    // four techniques adapted for spanish practice
    static let spanishTechniques: [ChallengeTechnique] = [
        ChallengeTechnique(
            title: "Inicio suave",
            difficulty: .easy,
            hint: "Comienza cada palabra con calma, sin forzar la voz ni apresurarte.",
            tip: "Relaja los músculos y comienza a hablar suavemente."
        ),
        ChallengeTechnique(
            title: "Contactos suaves",
            difficulty: .easy,
            hint: "Pronuncia las palabras con movimientos suaves de los labios y la lengua.",
            tip: "Evita presionar demasiado los labios al producir los sonidos."
        ),
        ChallengeTechnique(
            title: "Habla prolongada",
            difficulty: .intermediate,
            hint: "Alarga ligeramente las vocales y conecta las palabras con suavidad.",
            tip: "Habla lentamente y mantén un ritmo cómodo."
        ),
        ChallengeTechnique(
            title: "Pausas y frases",
            difficulty: .intermediate,
            hint: "Divide la oración en frases cortas y realiza pausas naturales.",
            tip: "Respira tranquilamente entre las frases y continúa sin apurarte."
        )
    ]

    // original english sounds
    static let sounds: [SpeechSound] = [
        SpeechSound(
            id: "TH",
            symbol: "TH",
            name: "TH Sound",
            placementTip: "Place your tongue gently between your teeth and let the airflow begin before you add your voice.",
            patterns: ["th"],
            prompts: [
                "Think it through",
                "Thank them both",
                "The three of them walked together along the smooth path, breathing through every thoughtful moment.",
                "On Thursday, I thanked them, I gathered my things, and I set off.",
                "I can ease into every th sound and take my time. If I bump on a tough word, I breathe, think nothing of it, and thank myself for trying.",
                "Thanks for calling — I think the earliest the three of us can meet is this Thursday, and that works for both of them.",
                "Every Thursday I think through the things I want to get done. I gather my thoughts, thank my brother for the ride, and set off on the northern path. I never thought I would enjoy those thoughtful mornings this much.",
                "Thank you all for being here tonight. I want to thank the three people who thought this theme was worth it. Together, I think we can push through anything, and that is the honest truth."
            ]
        ),
        SpeechSound(
            id: "SH",
            symbol: "SH",
            name: "SH Sound",
            placementTip: "Round your lips slightly and let a smooth stream of air flow for the shhh without tensing your jaw.",
            patterns: ["sh"],
            prompts: [
                "She should share",
                "Fresh fish dish",
                "She slowly showed the shining shells she gathered along the shore this morning.",
                "She washed the dishes, she shined the shelves, and she finished her shift.",
                "I can ease gently into every sh and slow right down. If I bump on a word, I relax my shoulders, take a breath, and push on without shame.",
                "Hi, this is Shane — I wanted to check whether the shipment shipped, and if not, should we reschedule for a shorter shift?",
                "This morning I rushed down to the shore before sunrise. I washed the fresh shells I found and showed them to my sister. I wished the shining afternoon would not finish so soon.",
                "Thank you all for showing up for the show tonight. I should share how much your support has shaped this shop. Together we should push forward, and I am sure we will shine."
            ]
        ),
        SpeechSound(
            id: "CH",
            symbol: "CH",
            name: "CH Sound",
            placementTip: "Start with a light tongue tap behind your teeth, then release the air softly into the ch.",
            patterns: ["ch"],
            prompts: [
                "Choose a chair",
                "Rich cheese chunk",
                "Charlie slowly reached for the cheese and chose a chunk for each cheerful child.",
                "I checked the chairs, I chopped the cherries, and I chose the cheese.",
                "I can ease into each ch and take my time. If I catch on a word, I breathe, cheer myself on, and reach the end without rushing.",
                "Hi Charlotte — I wanted to check on the charge for the chairs, and to ask whether we can change the launch to a cheaper choice.",
                "Each morning I choose a chair by the kitchen and check my list. I chop cherries, reach for the cheese, and chat with the children. I never thought such small choices could touch my whole day.",
                "Thank you for the chance to speak to each of you. I want to reach every child in this church with one message. Choose to cheer each other on, and cherish every chance you get."
            ]
        ),
        SpeechSound(
            id: "Z",
            symbol: "Z",
            name: "Z Sound",
            placementTip: "Let your voice buzz gently as the air flows over your tongue — keep it relaxed, not forced.",
            patterns: ["z"],
            prompts: [
                "Zip the zone",
                "Lazy zebra buzz",
                "The lazy zebra slowly gazed at the buzzing bees as the breeze drifted across the zoo.",
                "I organized the zones, I froze the prizes, and I zipped up the bags.",
                "I can ease into every z and let it buzz out slowly. If I freeze on a word, I relax, breathe, and amaze myself by staying calm.",
                "Hi Zack — I realized the prizes are frozen in the freezer, so does it make sense to organize the zones before noon?",
                "On lazy days I gaze at the buzzing bees by the zigzag fence. I realize how the breeze whizzes across the cozy zoo. It amazes me how quickly the hours seem to freeze.",
                "Thank you all for the prize and the dazzling praise tonight. I realize how much this organization amazes me. Let us seize this moment and buzz with fresh energy."
            ]
        ),
        SpeechSound(
            id: "S",
            symbol: "S",
            name: "S Sound",
            placementTip: "Keep your tongue light behind your teeth and let a steady, soft stream of air create the s.",
            patterns: ["s"],
            prompts: [
                "Sit in silence",
                "Sunny seaside stroll",
                "Sam slowly strolled past the sandy seashore as several seals swam softly by.",
                "I set the table, I sliced the bread, and I served the soup.",
                "I can ease into every s and let it slide out softly. If I stick on a word, I slow down, breathe, and stay steady without stress.",
                "Hi Sarah — I wanted to say the samples shipped safely, so should we set up a session to see how the sales system works?",
                "Most mornings I sit by the sunny seashore and watch the seals swim. I sip sweet soda while my sisters search for sparkling stones. It surprises me how silent and still the sea can seem.",
                "Thank you, everyone, for sitting with us this special evening. I want to say how proud I am of this steady, sincere team. Let us stay strong, stay steady, and see this season through."
            ]
        ),
        SpeechSound(
            id: "R",
            symbol: "R",
            name: "R Sound",
            placementTip: "Relax your tongue and let it curl loosely — avoid tightening your throat on the r.",
            patterns: ["r"],
            prompts: [
                "Read the road",
                "Bright red barn",
                "Rachel slowly rowed the red raft around the rocky river as the rain drifted near.",
                "I read the report, I repaired the truck, and I raced right home.",
                "I can ease into every r and roll through it slowly. If I trip on a word, I relax, breathe, and remind myself to stay ready.",
                "Hi Ryan — I wanted to run through the report, and to ask whether the rental arrives before the rest of the crew returns.",
                "Every morning I rise early and run around the river road. I race past the row of trees and reach the ridge right on time. It rewards me to return refreshed and ready for the rest of the day.",
                "Thank you for the warm welcome to this remarkable room. I want to recognize every person who arrived ready to work. Let us rise together, remain strong, and reach our real goal."
            ]
        ),
        SpeechSound(
            id: "L",
            symbol: "L",
            name: "L Sound",
            placementTip: "Rest the tip of your tongue lightly behind your top teeth and let your voice flow around it.",
            patterns: ["l"],
            prompts: [
                "Look and listen",
                "Little lucky lamb",
                "Lily slowly lounged by the lovely little lake as the light lingered low.",
                "I lit the lamp, I locked the gate, and I left the little cabin.",
                "I can ease into every l and let it flow slowly. If I lock on a word, I relax, breathe, and let it roll along calmly.",
                "Hi Laura — I wanted to let you know the delivery is a little late, so shall we call later to plan the final layout?",
                "On lazy evenings I lounge by the little lake and watch the light fade. I listen to the lively frogs call along the low stone wall. It always leaves me feeling calm and lucky.",
                "Thank you all for filling this lovely hall tonight. I would love to tell you how long we have looked forward to this. Let us celebrate, laugh a little, and let the lively evening roll along."
            ]
        ),
        SpeechSound(
            id: "M",
            symbol: "M",
            name: "M Sound",
            placementTip: "Close your lips softly and let the sound hum through your nose without pressing hard.",
            patterns: ["m"],
            prompts: [
                "Make more music",
                "Warm summer morning",
                "Mia slowly made a warm meal as the morning music hummed among the rooms.",
                "I made the meal, I mopped the mat, and I moved the mugs.",
                "I can ease into every m and hum it out slowly. If I get stuck on a word, I relax, breathe, and move on mindfully.",
                "Hi Marcus — I wanted to mention the meeting moved to Monday morning, so may I ask if that time remains manageable for most of them?",
                "Most mornings I make a warm meal and hum a merry melody. I move calmly among my family as the room grows immensely loud. It amazes me how much those small moments mean to me.",
                "Thank you, everyone, for making time to meet me this morning. I want to mention how much this moment means to our team. Let us move forward mindfully and remember what matters most."
            ]
        )
    ]

    // spanish sounds with four exercises each
    static let spanishSounds: [SpeechSound] = [

        SpeechSound(
            id: "ES-P",
            symbol: "P",
            name: "Sonido P",
            placementTip: "Junta los labios suavemente y sepáralos para producir el sonido P, evitando ejercer demasiada presión.",
            patterns: ["p"],
            prompts: [
                "Papá prepara pan.",
                "Pedro pinta una pared pequeña.",
                "Paula pasea por el parque mientras Pedro prepara un pequeño picnic.",
                "Por la mañana, Pedro prepara pan, Paula pone los platos y papá prepara el desayuno para compartir."
            ]
        ),

        SpeechSound(
            id: "ES-M",
            symbol: "M",
            name: "Sonido M",
            placementTip: "Junta los labios suavemente y deja que el sonido M resuene por la nariz, sin presionarlos demasiado.",
            patterns: ["m"],
            prompts: [
                "Mi mamá me mira.",
                "María mueve las manos mientras murmura una melodía.",
                "Mi mamá me muestra muchas maneras de mantener la calma mientras hablamos.",
                "Mañana me reuniré con mis amigos, mientras mi mamá prepara una merienda para compartir."
            ]
        )
    ]

    // looks up a sound by its identifier
    static func sound(id: String) -> SpeechSound? {
        (sounds + spanishSounds).first { $0.id == id }
    }
}
