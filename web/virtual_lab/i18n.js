/**
 * Questly Virtual Lab Multilingual Localization System
 * Supports: English ('en'), Tamil ('ta'), Hindi ('hi'), Odia ('or')
 */
(function () {
  const translations = {
    en: {
      questly_virtual_lab: "🧪 QUESTLY VIRTUAL LAB",
      titration: "Acid–Base Titration",
      smelting: "Smelting",
      calorimetry: "Calorimetry",
      flametest: "Flame Test",
      step_1: "Concept",
      step_2: "Apparatus",
      step_3: "Cupboard",
      step_4: "Experiment",
      step_5: "Report",
      score_label: "Score",
      stage1_tag: "STAGE 1 • THEORY & SAFETY GUIDE",
      stage1_difficulty: "Interactive Pre-Lab",
      stage1_title: "Neutralization Reaction Principles",
      stage1_subtitle: "Explore the core principles, apparatus, solutions, and standard procedure before entering the virtual workbench.",
      card_principle_tag: "Chemical Principle",
      card_principle_heading: "Core Principle",
      card_principle_desc: "Acid and base neutralize each other to produce salt and water.",
      card_apparatus_tag: "Apparatus Blueprint",
      card_apparatus_heading: "Volumetric Glassware",
      card_apparatus_desc: "Precision volumetric measurement using burettes and pipettes.",
      card_solutions_tag: "Chemical Reagents",
      card_solutions_heading: "Standard Solutions",
      card_solutions_desc: "0.100 M HCl analyte and 0.100 M NaOH titrant with phenolphthalein.",
      card_procedure_tag: "Standard Procedure",
      card_procedure_heading: "Titration Method",
      card_procedure_desc: "Slow dropwise addition until the very first pale pink endpoint.",
      btn_learn_more: "Learn More 🔍",
      safety_protocol: "⚠️ LAB SAFETY PROTOCOL: Always wear safety goggles & lab coat. Concentrated acids and bases cause severe chemical burns. Flush immediately with water in case of contact.",
      btn_enter_apparatus: "Enter Apparatus Bay ➔",
      stage2_tag: "STAGE 2 • APPARATUS SELECTION",
      stage2_title: "Equip the Workbench",
      stage2_subtitle: "Select all necessary volumetric glassware and lab hardware from the shelves.",
      apparatus_checklist_title: "Equipment Selected",
      btn_proceed_reagents: "Proceed to Chemical Reagents ➔",
      stage3_tag: "STAGE 3 • CHEMICAL REAGENTS CUPBOARD",
      stage3_title: "Select Standard Reagents",
      stage3_subtitle: "Choose the correct acid analyte, alkaline titrant, and pH indicator.",
      btn_enter_workbench: "Enter Virtual Workbench ➔",
      stage4_tag: "STAGE 4 • HANDS-ON TITRATION EXPERIMENT",
      stage4_title: "Interactive Titration Workbench",
      stage4_subtitle: "Operate the burette stopcock valve to deliver titrant dropwise into the analyte flask.",
      btn_add_analyte: "1. Add 10 mL Analyte (HCl)",
      btn_add_indicator: "2. Add Indicator (Phenolphthalein)",
      btn_fill_burette: "3. Fill Burette (0.100 M NaOH)",
      btn_stop_valve: "STOP VALVE",
      btn_slow_drip: "SLOW DRIP (0.1 mL)",
      btn_fast_flow: "FAST FLOW (0.4 mL)",
      btn_reset_exp: "RESET APPARATUS",
      btn_generate_report: "Generate Lab Report ➔",
      burette_reading_lbl: "Burette Reading:",
      titrant_dispensed_lbl: "Titrant Dispensed:",
      ph_lbl: "pH:",
      solution_state_lbl: "Solution State:",
      state_acidic: "Acidic / Colorless",
      state_neutral: "Neutralized (Pale Pink)",
      state_basic: "Basic / Over-Titrated (Magenta)",
      fb_initial: "Fill the conical flask with 10 mL 0.100 M HCl and add 2-3 drops of phenolphthalein.",
      fb_analyte_added: "10 mL HCl added to conical flask! Now add 2-3 drops of phenolphthalein indicator.",
      fb_indicator_added: "Phenolphthalein added! Click the Burette stopcock valve to begin dropwise titration.",
      fb_burette_filled: "Burette filled with 0.100 M NaOH titrant! Open valve to begin titration.",
      fb_endpoint: "Endpoint reached! The solution turned faint pale pink at {vol} mL. Reaction neutralized!",
      fb_overtitrated: "Over-titration! The solution turned dark magenta (pH > 9.5). You added too much NaOH! Click RESET to try again.",
      stage5_tag: "STAGE 5 • LAB REPORT & RESULTS",
      report_title: "Acid–Base Titration Summary Sheet",
      lbl_acid_volume: "Volume of Acid (HCl):",
      lbl_base_volume: "Volume of Base (NaOH):",
      lbl_acid_conc: "Concentration of HCl:",
      lbl_calculated_molarity: "Calculated Molarity:",
      mastery_badge: "TITRATION MASTER ⭐⭐⭐",
      btn_return_roadmap: "Return to Roadmap & Claim Rewards ➔",
      
      // Apparatus items
      app_burette: "Burette (50 mL)",
      app_conical_flask: "Conical Flask (250 mL)",
      app_volumetric_pipette: "Volumetric Pipette (10 mL)",
      app_retort_stand: "Retort Stand & Clamp",
      app_pipette_pump: "Pipette Pump / Filler",
      app_white_tile: "White Tile",
      app_beaker: "Griffin Beaker",
      app_furnace: "Blast Furnace",
      app_bunsen: "Bunsen Burner",
      app_watch_glass: "Watch Glass",
      
      // Chemical reagents
      reagent_hcl: "Hydrochloric Acid (0.100 M HCl)",
      reagent_naoh: "Sodium Hydroxide (0.100 M NaOH)",
      reagent_phenolphthalein: "Phenolphthalein Indicator",
      reagent_h2so4: "Sulfuric Acid (Conc)",
      reagent_methyl_orange: "Methyl Orange",
      reagent_ethanol: "Ethanol (95%)"
    },

    ta: {
      questly_virtual_lab: "🧪 குவெஸ்ட்லி மெய்நிகர் ஆய்வகம்",
      titration: "அமிலம்–கார தரம் பார்த்தல்",
      smelting: "உலோக உருக்குதல்",
      calorimetry: "வெப்ப அளவியல்",
      flametest: "சுடர் சோதனை",
      step_1: "கோட்பாடு",
      step_2: "கருவிகள்",
      step_3: "அலமாரி",
      step_4: "சோதனை",
      step_5: "அறிக்கை",
      score_label: "மதிப்பெண்",
      stage1_tag: "நிலை 1 • கோட்பாடு & பாதுகாப்பு வழிகாட்டி",
      stage1_difficulty: "ஊடாடும் முன் ஆய்வகம்",
      stage1_title: "நடுநிலையாக்கல் வினை கோட்பாடுகள்",
      stage1_subtitle: "மெய்நிகர் பணிமேடைக்குச் செல்வதற்கு முன் அடிப்படைக் கோட்பாடுகள், கருவிகள், கரைசல்கள் மற்றும் நிலையான நடைமுறைகளை ஆராயுங்கள்.",
      card_principle_tag: "வேதியியல் கோட்பாடு",
      card_principle_heading: "அடிப்படைக் கோட்பாடு",
      card_principle_desc: "அமிலமும் காரமும் ஒன்றையொன்று நடுநிலையாக்கி உப்பையும் நீரையும் உருவாக்குகின்றன.",
      card_apparatus_tag: "கருவிகள் வரைபடம்",
      card_apparatus_heading: "கன அளவு கண்ணாடிப் பொருட்கள்",
      card_apparatus_desc: "பியூரெட் மற்றும் பைப்பெட் பயன்படுத்தி துல்லியமான கன அளவு அளவீடு.",
      card_solutions_tag: "வேதிப்பொருட்கள்",
      card_solutions_heading: "நிலையான கரைசல்கள்",
      card_solutions_desc: "0.100 M HCl மற்றும் 0.100 M NaOH கரைசல்கள் மற்றும் பினாப்தலீன்.",
      card_procedure_tag: "நிலையான செயல்முறை",
      card_procedure_heading: "தரம் பார்த்தல் முறை",
      card_procedure_desc: "மெல்லிய இளஞ்சிவப்பு நிறம் தோன்றும் வரை மெதுவாக சொட்டு சொட்டாகச் சேர்த்தல்.",
      btn_learn_more: "மேலும் அறிக 🔍",
      safety_protocol: "⚠️ ஆய்வக பாதுகாப்பு விதிமுறை: எப்போதும் பாதுகாப்பு கண்ணாடி மற்றும் மேலங்கி அணியவும். அமிலங்கள் மற்றும் காரங்கள் கடுமையான தீக்காயங்களை ஏற்படுத்தும்.",
      btn_enter_apparatus: "கருவிகள் அறைக்குச் செல்க ➔",
      stage2_tag: "நிலை 2 • கருவிகள் தேர்வு",
      stage2_title: "பணிமேடையை ஆயத்தப்படுத்துங்கள்",
      stage2_subtitle: "அலமாரிகளில் இருந்து தேவையான அனைத்து கண்ணாடிப் பொருட்கள் மற்றும் ஆய்வகக் கருவிகளைத் தேர்ந்தெடுக்கவும்.",
      apparatus_checklist_title: "தேர்ந்தெடுக்கப்பட்ட கருவிகள்",
      btn_proceed_reagents: "வேதிப்பொருட்களுக்குச் செல்க ➔",
      stage3_tag: "நிலை 3 • வேதிப்பொருட்கள் அலமாரி",
      stage3_title: "நிலையான வேதிப்பொருட்களைத் தேர்ந்தெடுக்கவும்",
      stage3_subtitle: "சரியான அமில பகுப்பாய்வு திரவம், கார கரைசல் மற்றும் pH நிறங்காட்டியைத் தேர்ந்தெடுக்கவும்.",
      btn_enter_workbench: "மெய்நிகர் பணிமேடைக்குச் செல்க ➔",
      stage4_tag: "நிலை 4 • நேரடி தரம் பார்த்தல் சோதனை",
      stage4_title: "ஊடாடும் தரம் பார்த்தல் பணிமேடை",
      stage4_subtitle: "பியூரெட் வால்வை இயக்கி பகுப்பாய்வு குடுவையில் சொட்டு சொட்டாக கரைசலைச் சேர்க்கவும்.",
      btn_add_analyte: "1. 10 mL பகுப்பாய்வு திரவம் சேர் (HCl)",
      btn_add_indicator: "2. நிறங்காட்டி சேர் (பினாப்தலீன்)",
      btn_fill_burette: "3. பியூரெட்டை நிரப்பு (0.100 M NaOH)",
      btn_stop_valve: "நிறுத்து",
      btn_slow_drip: "மெதுவான சொட்டு (0.1 mL)",
      btn_fast_flow: "வேகமான ஓட்டம் (0.4 mL)",
      btn_reset_exp: "கருவிகளை மீட்டமை",
      btn_generate_report: "ஆய்வக அறிக்கை உருவாக்கு ➔",
      burette_reading_lbl: "பியூரெட் அளவு:",
      titrant_dispensed_lbl: "வெளியேறிய கரைசல்:",
      ph_lbl: "pH:",
      solution_state_lbl: "கரைசல் நிலை:",
      state_acidic: "அமிலம் / நிறமற்றது",
      state_neutral: "நடுநிலையானது (மெல்லிய இளஞ்சிவப்பு)",
      state_basic: "காரம் / அதிக அளவு (கருஞ்சிவப்பு)",
      fb_initial: "கூம்பு வடிவ குடுவையில் 10 mL 0.100 M HCl நிரப்பி 2-3 சொட்டு பினாப்தலீன் சேர்க்கவும்.",
      fb_analyte_added: "குடுவையில் 10 mL HCl சேர்க்கப்பட்டது! இப்போது 2-3 சொட்டு பினாப்தலீன் நிறங்காட்டி சேர்க்கவும்.",
      fb_indicator_added: "பினாப்தலீன் சேர்க்கப்பட்டது! தரம் பார்த்தலைத் தொடங்க பியூரெட் வால்வைக் கிளிக் செய்யவும்.",
      fb_burette_filled: "பியூரெட்டில் 0.100 M NaOH நிரப்பப்பட்டது! தரம் பார்த்தலைத் தொடங்க வால்வைத் திறக்கவும்.",
      fb_endpoint: "முடிவு நிலை எட்டப்பட்டது! கரைசல் {vol} mL அளவில் மெல்லிய இளஞ்சிவப்பாக மாறியது. வினை நடுநிலையானது!",
      fb_overtitrated: "அதிக அளவு தரம் பார்த்தல்! கரைசல் கருஞ்சிவப்பாக மாறியது (pH > 9.5). அதிக NaOH சேர்க்கப்பட்டது! மீண்டும் முயற்சிக்க 'மீட்டமை' என்பதைக் கிளிக் செய்யவும்.",
      stage5_tag: "நிலை 5 • ஆய்வக அறிக்கை & முடிவுகள்",
      report_title: "அமிலம்–கார தரம் பார்த்தல் சுருக்க அறிக்கை",
      lbl_acid_volume: "அமிலத்தின் அளவு (HCl):",
      lbl_base_volume: "காரத்தின் அளவு (NaOH):",
      lbl_acid_conc: "HCl செறிவு:",
      lbl_calculated_molarity: "கணக்கிடப்பட்ட மோலாரிட்டி:",
      mastery_badge: "தரம் பார்த்தல் நிபுணர் ⭐⭐⭐",
      btn_return_roadmap: "பயண வழிக்குத் திரும்பி பரிசுகளைப் பெறுங்கள் ➔",
      
      app_burette: "பியூரெட் (50 mL)",
      app_conical_flask: "கூம்பு வடிவ குடுவை (250 mL)",
      app_volumetric_pipette: "அளவீட்டு பைப்பெட் (10 mL)",
      app_retort_stand: "தாங்கி மற்றும் பிடிப்பி",
      app_pipette_pump: "பைப்பெட் பம்ப் / ஃபில்லர்",
      app_white_tile: "வெள்ளை ஓடு",
      app_beaker: "பீக்கர்",
      app_furnace: "உலை",
      app_bunsen: "பன்சன் பர்னர்",
      app_watch_glass: "கண்ணாடி தட்டு",
      
      reagent_hcl: "ஹைட்ரோகுளோரிக் அமிலம் (0.100 M HCl)",
      reagent_naoh: "சோடியம் ஹைட்ராக்சைடு (0.100 M NaOH)",
      reagent_phenolphthalein: "பினாப்தலீன் நிறங்காட்டி",
      reagent_h2so4: "கந்தக அமிலம் (செறிவு)",
      reagent_methyl_orange: "மெத்தில் ஆரஞ்சு",
      reagent_ethanol: "எத்தனால் (95%)"
    },

    hi: {
      questly_virtual_lab: "🧪 क्वेस्टली वर्चुअल लैब",
      titration: "अम्ल–क्षार अनुमापन",
      smelting: "प्रगलन",
      calorimetry: "कैलोरीमिति",
      flametest: "ज्वाला परीक्षण",
      step_1: "सिद्धांत",
      step_2: "उपकरण",
      step_3: "अलमारी",
      step_4: "प्रयोग",
      step_5: "रिपोर्ट",
      score_label: "स्कोर",
      stage1_tag: "चरण 1 • सिद्धांत और सुरक्षा गाइड",
      stage1_difficulty: "इंटरैक्टिव प्री-लैब",
      stage1_title: "उदासीनीकरण अभिक्रिया के सिद्धांत",
      stage1_subtitle: "वर्चुअल वर्कबेंच में जाने से पहले मूल सिद्धांतों, उपकरणों, विलयनों और मानक प्रक्रिया का अन्वेषण करें।",
      card_principle_tag: "रासायनिक सिद्धांत",
      card_principle_heading: "मूल सिद्धांत",
      card_principle_desc: "अम्ल और क्षार एक दूसरे को उदासीन करके लवण और जल बनाते हैं।",
      card_apparatus_tag: "उपकरण खाका",
      card_apparatus_heading: "आयतनमितीय कांच के उपकरण",
      card_apparatus_desc: "ब्यूरेट और पिपेट का उपयोग करके सटीक आयतन माप।",
      card_solutions_tag: "रासायनिक अभिकर्मक",
      card_solutions_heading: "मानक विलयन",
      card_solutions_desc: "0.100 M HCl और 0.100 M NaOH विलयन और फेनोल्फथेलिन सूचक।",
      card_procedure_tag: "मानक प्रक्रिया",
      card_procedure_heading: "अनुमापन विधि",
      card_procedure_desc: "हल्का गुलाबी रंग आने तक बूंद-बूंद करके मिलाना।",
      btn_learn_more: "अधिक जानें 🔍",
      safety_protocol: "⚠️ प्रयोगशाला सुरक्षा नियम: हमेशा सुरक्षा चश्मा और लैब कोट पहनें। सांद्र अम्ल और क्षार गंभीर जलन पैदा करते हैं। संपर्क होने पर तुरंत पानी से धोएं।",
      btn_enter_apparatus: "उपकरण कक्ष में प्रवेश करें ➔",
      stage2_tag: "चरण 2 • उपकरण चयन",
      stage2_title: "वर्कबेंच को सुसज्जित करें",
      stage2_subtitle: "अलमारियों से सभी आवश्यक कांच के उपकरण और लैब हार्डवेयर चुनें।",
      apparatus_checklist_title: "चयनित उपकरण",
      btn_proceed_reagents: "रासायनिक अभिकर्मकों की ओर बढ़ें ➔",
      stage3_tag: "चरण 3 • रासायनिक अभिकर्मक अलमारी",
      stage3_title: "मानक अभिकर्मक चुनें",
      stage3_subtitle: "सही अम्ल विश्लेष्य, क्षारीय अनुमापक और pH सूचक चुनें।",
      btn_enter_workbench: "वर्चुअल वर्कबेंच में प्रवेश करें ➔",
      stage4_tag: "चरण 4 • प्रत्यक्ष अनुमापन प्रयोग",
      stage4_title: "इंटरैक्टिव अनुमापन वर्कबेंच",
      stage4_subtitle: "विश्लेष्य फ्लास्क में बूंद-बूंद अनुमापक डालने के लिए ब्यूरेट वाल्व चलाएं।",
      btn_add_analyte: "1. 10 mL विश्लेष्य जोड़ें (HCl)",
      btn_add_indicator: "2. सूचक जोड़ें (फेनोल्फथेलिन)",
      btn_fill_burette: "3. ब्यूरेट भरें (0.100 M NaOH)",
      btn_stop_valve: "वाल्व रोकें",
      btn_slow_drip: "धीमी बूंद (0.1 mL)",
      btn_fast_flow: "तेज प्रवाह (0.4 mL)",
      btn_reset_exp: "उपकरण रीसेट करें",
      btn_generate_report: "लैब रिपोर्ट तैयार करें ➔",
      burette_reading_lbl: "ब्यूरेट पाठ्यांक:",
      titrant_dispensed_lbl: "प्रवाहित अनुमापक:",
      ph_lbl: "pH:",
      solution_state_lbl: "विलयन की स्थिति:",
      state_acidic: "अम्लीय / रंगहीन",
      state_neutral: "उदासीन (हल्का गुलाबी)",
      state_basic: "क्षारीय / अधिक अनुमापित (गहरा गुलाबी)",
      fb_initial: "शंक्वाकार फ्लास्क में 10 mL 0.100 M HCl भरें और 2-3 बूंदें फेनोल्फथेलिन मिलाएं।",
      fb_analyte_added: "फ्लास्क में 10 mL HCl मिलाया गया! अब 2-3 बूंदें फेनोल्फथेलिन सूचक मिलाएं।",
      fb_indicator_added: "फेनोल्फथेलिन मिला दिया गया! बूंद-बूंद अनुमापन शुरू करने के लिए ब्यूरेट वाल्व पर क्लिक करें।",
      fb_burette_filled: "ब्यूरेट 0.100 M NaOH से भर गया! अनुमापन शुरू करने के लिए वाल्व खोलें।",
      fb_endpoint: "अंतिम बिंदु प्राप्त हुआ! {vol} mL पर विलयन हल्का गुलाबी हो गया। अभिक्रिया उदासीन हो गई!",
      fb_overtitrated: "अधिक अनुमापन! विलयन गहरा गुलाबी हो गया (pH > 9.5)। आपने बहुत अधिक NaOH मिला दिया! पुनः प्रयास के लिए रीसेट पर क्लिक करें।",
      stage5_tag: "चरण 5 • लैब रिपोर्ट और परिणाम",
      report_title: "अम्ल–क्षार अनुमापन सारांश पत्र",
      lbl_acid_volume: "अम्ल का आयतन (HCl):",
      lbl_base_volume: "क्षार का आयतन (NaOH):",
      lbl_acid_conc: "HCl की सांद्रता:",
      lbl_calculated_molarity: "परिकलित मोलरता:",
      mastery_badge: "अनुमापन विशेषज्ञ ⭐⭐⭐",
      btn_return_roadmap: "रोडमैप पर लौटें और पुरस्कार प्राप्त करें ➔",
      
      app_burette: "ब्यूरेट (50 mL)",
      app_conical_flask: "शंक्वाकार फ्लास्क (250 mL)",
      app_volumetric_pipette: "वॉल्यूमेट्रिक पिपेट (10 mL)",
      app_retort_stand: "रिटॉर्ट स्टैंड और क्लैंप",
      app_pipette_pump: "पिपेट पंप / फिलर",
      app_white_tile: "सफेद टाइल",
      app_beaker: "बीकर",
      app_furnace: "ब्लास्ट फर्नेस",
      app_bunsen: "बन्सन बर्नर",
      app_watch_glass: "वॉच ग्लास",
      
      reagent_hcl: "हाइड्रोक्लोरिक एसिड (0.100 M HCl)",
      reagent_naoh: "सोडियम हाइड्रॉक्साइड (0.100 M NaOH)",
      reagent_phenolphthalein: "फेनोल्फथेलिन सूचक",
      reagent_h2so4: "सल्फ्यूरिक एसिड (सांद्र)",
      reagent_methyl_orange: "मिथाइल ऑरेंज",
      reagent_ethanol: "इथेनॉल (95%)"
    },

    or: {
      questly_virtual_lab: "🧪 କ୍ୱେଷ୍ଟଲି ଭର୍ଚୁଆଲ୍ ଲାବ୍",
      titration: "ଅମ୍ଳ–କ୍ଷାର ଅନୁମାପନ",
      smelting: "ଧାତୁ ନିଷ୍କାସନ",
      calorimetry: "ତାପମାପନ",
      flametest: "ଶିଖା ପରୀକ୍ଷା",
      step_1: "ଧାରଣା",
      step_2: "ଉପକରଣ",
      step_3: "ଆଲମାରୀ",
      step_4: "ପରୀକ୍ଷଣ",
      step_5: "ରିପୋର୍ଟ",
      score_label: "ସ୍କୋର୍",
      stage1_tag: "ପର୍ଯ୍ୟାୟ ୧ • ତତ୍ତ୍ୱ ଏବଂ ସୁରକ୍ଷା ନିର୍ଦ୍ଦେଶାବଳୀ",
      stage1_difficulty: "ପାରସ୍ପରିକ ପ୍ରି-ଲାବ୍",
      stage1_title: "ପ୍ରଶମନ ପ୍ରତିକ୍ରିୟା ନୀତି",
      stage1_subtitle: "ଭର୍ଚୁଆଲ୍ କାର୍ଯ୍ୟକ୍ଷେତ୍ରକୁ ଯିବା ପୂର୍ବରୁ ମୂଳ ନୀତି, ଉପକରଣ, ଦ୍ରବଣ ଏବଂ ମାନକ ପ୍ରଣାଳୀ ଅନୁସନ୍ଧାନ କରନ୍ତୁ।",
      card_principle_tag: "ରାସାୟନିକ ନୀତି",
      card_principle_heading: "ମୂଳ ନୀତି",
      card_principle_desc: "ଅମ୍ଳ ଏବଂ କ୍ଷାର ପରସ୍ପରକୁ ପ୍ରଶମିତ କରି ଲବଣ ଏବଂ ଜଳ ସୃଷ୍ଟି କରନ୍ତି।",
      card_apparatus_tag: "ଉପକରଣ ବ୍ଲୁପ୍ରିଣ୍ଟ",
      card_apparatus_heading: "ଆୟତନିକ କାଚ ଉପକରଣ",
      card_apparatus_desc: "ବ୍ୟୁରେଟ୍ ଏବଂ ପାଇପେଟ୍ ବ୍ୟବହାର କରି ସଠିକ୍ ମାପ।",
      card_solutions_tag: "ରାସାୟନିକ ଅଭିକର୍ମକ",
      card_solutions_heading: "ମାନକ ଦ୍ରବଣ",
      card_solutions_desc: "୦.୧୦୦ M HCl ଏବଂ ୦.୧୦୦ M NaOH ସହିତ ଫିନୋଲଫଥାଲିନ୍ ସୂଚକ।",
      card_procedure_tag: "ମାନକ ପ୍ରଣାଳୀ",
      card_procedure_heading: "ଅନୁମାପନ ପ୍ରଣାଳୀ",
      card_procedure_desc: "ହାଲୁକା ଗୋଲାପୀ ରଙ୍ଗ ଆସିବା ପର୍ଯ୍ୟନ୍ତ ଧୀରେ ଧୀରେ ଟୋପା ଟୋପା ମିଶାଇବା।",
      btn_learn_more: "ଅଧିକ ଜାଣନ୍ତୁ 🔍",
      safety_protocol: "⚠️ ପରୀକ୍ଷାଗାର ସୁରକ୍ଷା ନିୟମ: ସର୍ବଦା ସୁରକ୍ଷା ଚଷମା ଏବଂ ଲ୍ୟାବ୍ କୋଟ୍ ପିନ୍ଧନ୍ତୁ। ଏସିଡ୍ ଏବଂ କ୍ଷାର ଗମ୍ଭୀର କ୍ଷତ ସୃଷ୍ଟି କରିପାରେ। ସଂସ୍ପର୍ଶରେ ଆସିଲେ ତୁରନ୍ତ ପାଣିରେ ଧୁଅନ୍ତୁ।",
      btn_enter_apparatus: "ଉପକରଣ କକ୍ଷକୁ ଯାଆନ୍ତୁ ➔",
      stage2_tag: "ପର୍ଯ୍ୟାୟ ୨ • ଉପକରଣ ଚୟନ",
      stage2_title: "କାର୍ଯ୍ୟକ୍ଷେତ୍ର ପ୍ରସ୍ତୁତ କରନ୍ତୁ",
      stage2_subtitle: "ଆଲମାରୀରୁ ଆବଶ୍ୟକୀୟ କାଚ ଉପକରଣ ଏବଂ ଲ୍ୟାବ୍ ଉପକରଣ ଚୟନ କରନ୍ତୁ।",
      apparatus_checklist_title: "ଚୟନିତ ଉପକରଣ",
      btn_proceed_reagents: "ରାସାୟନିକ ଅଭିକର୍ମକକୁ ଯାଆନ୍ତୁ ➔",
      stage3_tag: "ପର୍ଯ୍ୟାୟ ୩ • ରାସାୟନିକ ଅଭିକର୍ମକ ଆଲମାରୀ",
      stage3_title: "ମାନକ ଅଭିକର୍ମକ ଚୟନ କରନ୍ତୁ",
      stage3_subtitle: "ସଠିକ୍ ଏସିଡ୍ ବିଶ୍ଳେଷ୍ୟ, କ୍ଷାରୀୟ ଟିଟ୍ରାଣ୍ଟ ଏବଂ pH ସୂଚକ ବାଛନ୍ତୁ।",
      btn_enter_workbench: "ଭର୍ଚୁଆଲ୍ କାର୍ଯ୍ୟକ୍ଷେତ୍ରକୁ ଯାଆନ୍ତୁ ➔",
      stage4_tag: "ପର୍ଯ୍ୟାୟ ୪ • ପ୍ରତ୍ୟକ୍ଷ ଅନୁମାପନ ପରୀକ୍ଷଣ",
      stage4_title: "ପାରସ୍ପରିକ ଅନୁମାପନ କାର୍ଯ୍ୟକ୍ଷେତ୍ର",
      stage4_subtitle: "ବିଶ୍ଳେଷ୍ୟ ଫ୍ଲାସ୍କରେ ଟିଟ୍ରାଣ୍ଟ ଟୋପା ଟୋପା ପକାଇବା ପାଇଁ ବ୍ୟୁରେଟ୍ ଭାଲ୍ଭ ଚଲାନ୍ତୁ।",
      btn_add_analyte: "୧. ୧୦ mL ବିଶ୍ଳେଷ୍ୟ ଯୋଗ କରନ୍ତୁ (HCl)",
      btn_add_indicator: "୨. ସୂଚକ ଯୋଗ କରନ୍ତୁ (ଫିନୋଲଫଥାଲିନ୍)",
      btn_fill_burette: "୩. ବ୍ୟୁରେଟ୍ ପୂରଣ କରନ୍ତୁ (୦.୧୦୦ M NaOH)",
      btn_stop_valve: "ଭାଲ୍ଭ ବନ୍ଦ କରନ୍ତୁ",
      btn_slow_drip: "ଧୀର ଟୋପା (୦.୧ mL)",
      btn_fast_flow: "ଦ୍ରୁତ ପ୍ରବାହ (୦.୪ mL)",
      btn_reset_exp: "ଉପକରଣ ପୁନଃସେଟ୍ କରନ୍ତୁ",
      btn_generate_report: "ଲାବ୍ ରିପୋର୍ଟ ପ୍ରସ୍ତୁତ କରନ୍ତୁ ➔",
      burette_reading_lbl: "ବ୍ୟୁରେଟ୍ ପାଠ୍ୟାଙ୍କ:",
      titrant_dispensed_lbl: "ନିର୍ଗତ ଟିଟ୍ରାଣ୍ଟ:",
      ph_lbl: "pH:",
      solution_state_lbl: "ଦ୍ରବଣର ଅବସ୍ଥା:",
      state_acidic: "ଅମ୍ଳୀୟ / ରଙ୍ଗହୀନ",
      state_neutral: "ପ୍ରଶମିତ (ହାଲୁକା ଗୋଲାପୀ)",
      state_basic: "କ୍ଷାରୀୟ / ଅତ୍ୟଧିକ (ଗାଢ଼ ଗୋଲାପୀ)",
      fb_initial: "କୋନିକାଲ୍ ଫ୍ଲାସ୍କରେ ୧୦ mL ୦.୧୦୦ M HCl ଭରନ୍ତୁ ଏବଂ ୨-୩ ଟୋପା ଫିନୋଲଫଥାଲିନ୍ ମିଶାନ୍ତୁ।",
      fb_analyte_added: "ଫ୍ଲାସ୍କରେ ୧୦ mL HCl ମିଶାଗଲା! ଏବେ ୨-୩ ଟୋପା ଫିନୋଲଫଥାଲିନ୍ ସୂଚକ ମିଶାନ୍ତୁ।",
      fb_indicator_added: "ଫିନୋଲଫଥାଲିନ୍ ମିଶାଗଲା! ଟୋପା ଟୋପା ଅନୁମାପନ ଆରମ୍ଭ କରିବାକୁ ବ୍ୟୁରେଟ୍ ଭାଲ୍ଭ କ୍ଲିକ୍ କରନ୍ତୁ।",
      fb_burette_filled: "ବ୍ୟୁରେଟ୍ ୦.୧୦୦ M NaOH ରେ ପୂର୍ଣ୍ଣ ହେଲା! ଅନୁମାପନ ଆରମ୍ଭ କରିବାକୁ ଭାଲ୍ଭ ଖୋଲନ୍ତୁ।",
      fb_endpoint: "ପ୍ରଶମନ ବିନ୍ଦୁ ମିଳିଗଲା! ଦ୍ରବଣ {vol} mL ରେ ହାଲୁକା ଗୋଲାପୀ ହୋଇଗଲା। ପ୍ରତିକ୍ରିୟା ପ୍ରଶମିତ ହେଲା!",
      fb_overtitrated: "ଅତ୍ୟଧିକ ଅନୁମାପନ! ଦ୍ରବଣ ଗାଢ଼ ଗୋଲାପୀ ହୋଇଗଲା (pH > ୯.୫)। ଆପଣ ଅଧିକ NaOH ମିଶାଇ ଦେଲେ! ପୁନର୍ବାର ଚେଷ୍ଟା କରିବାକୁ ପୁନଃସେଟ୍ କ୍ଲିକ୍ କରନ୍ତୁ।",
      stage5_tag: "ପର୍ଯ୍ୟାୟ ୫ • ଲାବ୍ ରିପୋର୍ଟ ଏବଂ ଫଳାଫଳ",
      report_title: "ଅମ୍ଳ–କ୍ଷାର ଅନୁମାପନ ସାରାଂଶ ପତ୍ର",
      lbl_acid_volume: "ଅମ୍ଳର ଆୟତନ (HCl):",
      lbl_base_volume: "କ୍ଷାରର ଆୟତନ (NaOH):",
      lbl_acid_conc: "HCl ର ଗାଢ଼ତା:",
      lbl_calculated_molarity: "ଗଣନା କରାଯାଇଥିବା ମୋଲାରିଟି:",
      mastery_badge: "ଅନୁମାପନ ନିପୁଣ ⭐⭐⭐",
      btn_return_roadmap: "ରୋଡମ୍ୟାପ୍ କୁ ଫେରି ପୁରସ୍କାର ହାସଲ କରନ୍ତୁ ➔",
      
      app_burette: "ବ୍ୟୁରେଟ୍ (୫୦ mL)",
      app_conical_flask: "କୋନିକାଲ୍ ଫ୍ଲାସ୍କ (୨୫୦ mL)",
      app_volumetric_pipette: "ଭଲ୍ୟୁମେଟ୍ରିକ୍ ପାଇପେଟ୍ (୧୦ mL)",
      app_retort_stand: "ରିଟର୍ଟ ଷ୍ଟାଣ୍ଡ ଏବଂ କ୍ଲାମ୍ପ",
      app_pipette_pump: "ପାଇପେଟ୍ ପମ୍ପ୍ / ଫିଲର୍",
      app_white_tile: "ଧଳା ଟାଇଲ୍",
      app_beaker: "ବିକର୍",
      app_furnace: "ବ୍ଲାଷ୍ଟ ଫର୍ଣ୍ଣେସ୍",
      app_bunsen: "ବୁନସେନ୍ ବର୍ଣ୍ଣର୍",
      app_watch_glass: "ୱାଚ୍ ଗ୍ଲାସ୍",
      
      reagent_hcl: "ହାଇଡ୍ରୋକ୍ଲୋରିକ୍ ଏସିଡ୍ (୦.୧୦୦ M HCl)",
      reagent_naoh: "ସୋଡିୟମ୍ ହାଇଡ୍ରୋକ୍ସାଇଡ୍ (୦.୧୦୦ M NaOH)",
      reagent_phenolphthalein: "ଫିନୋଲଫଥାଲିନ୍ ସୂଚକ",
      reagent_h2so4: "ସଲଫ୍ୟୁରିକ୍ ଏସିଡ୍ (ଗାଢ଼)",
      reagent_methyl_orange: "ମିଥାଇଲ୍ ଅରେଞ୍ଜ",
      reagent_ethanol: "ଇଥାନଲ୍ (୯୫%)"
    }
  };

  let currentLang = 'en';

  function resolveLanguage() {
    try {
      const urlParams = new URLSearchParams(window.location.search);
      const param = urlParams.get('lang');
      if (param && translations[param]) return param;
    } catch (_) {}
    try {
      const stored = localStorage.getItem('questly_language');
      if (stored && translations[stored]) return stored;
    } catch (_) {}
    return 'en';
  }

  function t(key, args) {
    const dict = translations[currentLang] || translations['en'];
    let str = dict[key] || translations['en'][key] || key;
    if (args) {
      Object.keys(args).forEach(k => {
        str = str.replace(new RegExp('\\{' + k + '\\}', 'g'), args[k]);
      });
    }
    return str;
  }

  function applyLanguage(lang) {
    if (!translations[lang]) lang = 'en';
    currentLang = lang;
    document.documentElement.lang = lang;

    // 1. Header and Module Names
    const badge = document.querySelector('.lab-badge');
    if (badge) badge.textContent = t('questly_virtual_lab');
    const modTitle = document.getElementById('currentModuleName');
    if (modTitle) modTitle.textContent = t('titration');

    // 2. Module Selector Tabs
    const tabTitration = document.querySelector('.module-tab[data-module="titration"] .tab-text');
    if (tabTitration) tabTitration.textContent = t('titration');
    const tabSmelting = document.querySelector('.module-tab[data-module="smelting"] .tab-text');
    if (tabSmelting) tabSmelting.textContent = t('smelting');
    const tabCalorimetry = document.querySelector('.module-tab[data-module="calorimetry"] .tab-text');
    if (tabCalorimetry) tabCalorimetry.textContent = t('calorimetry');
    const tabFlametest = document.querySelector('.module-tab[data-module="flametest"] .tab-text');
    if (tabFlametest) tabFlametest.textContent = t('flametest');

    // 3. Stage Stepper Pills
    const step1 = document.querySelector('.step-pill[data-stage="1"] .step-lbl');
    if (step1) step1.textContent = t('step_1');
    const step2 = document.querySelector('.step-pill[data-stage="2"] .step-lbl');
    if (step2) step2.textContent = t('step_2');
    const step3 = document.querySelector('.step-pill[data-stage="3"] .step-lbl');
    if (step3) step3.textContent = t('step_3');
    const step4 = document.querySelector('.step-pill[data-stage="4"] .step-lbl');
    if (step4) step4.textContent = t('step_4');
    const step5 = document.querySelector('.step-pill[data-stage="5"] .step-lbl');
    if (step5) step5.textContent = t('step_5');

    // 4. Stage 1: Theory
    const s1Tag = document.querySelector('#stage1 .stage-tag');
    if (s1Tag) s1Tag.textContent = t('stage1_tag');
    const s1Diff = document.querySelector('#stage1 .difficulty-tag');
    if (s1Diff) s1Diff.textContent = t('stage1_difficulty');
    const s1Title = document.getElementById('stage1Title');
    if (s1Title) s1Title.textContent = t('stage1_title');
    const s1Sub = document.getElementById('stage1Subtitle');
    if (s1Sub) s1Sub.textContent = t('stage1_subtitle');

    const cardPrincTag = document.querySelector('#cardPrinciple .card-tag');
    if (cardPrincTag) cardPrincTag.textContent = t('card_principle_tag');
    const cardPrincHead = document.getElementById('principleHeading');
    if (cardPrincHead) cardPrincHead.textContent = t('card_principle_heading');
    const cardPrincDesc = document.getElementById('principleDesc');
    if (cardPrincDesc) cardPrincDesc.textContent = t('card_principle_desc');

    const cardAppTag = document.querySelector('#cardApparatus .card-tag');
    if (cardAppTag) cardAppTag.textContent = t('card_apparatus_tag');
    const cardAppHead = document.getElementById('apparatusHeading');
    if (cardAppHead) cardAppHead.textContent = t('card_apparatus_heading');
    const cardAppDesc = document.getElementById('apparatusDesc');
    if (cardAppDesc) cardAppDesc.textContent = t('card_apparatus_desc');

    const cardSolTag = document.querySelector('#cardSolutions .card-tag');
    if (cardSolTag) cardSolTag.textContent = t('card_solutions_tag');
    const cardSolHead = document.getElementById('solutionsHeading');
    if (cardSolHead) cardSolHead.textContent = t('card_solutions_heading');
    const cardSolDesc = document.getElementById('solutionsDesc');
    if (cardSolDesc) cardSolDesc.textContent = t('card_solutions_desc');

    const cardProcTag = document.querySelector('#cardProcedure .card-tag');
    if (cardProcTag) cardProcTag.textContent = t('card_procedure_tag');
    const cardProcHead = document.getElementById('procedureHeading');
    if (cardProcHead) cardProcHead.textContent = t('card_procedure_heading');
    const cardProcDesc = document.getElementById('procedureDesc');
    if (cardProcDesc) cardProcDesc.textContent = t('card_procedure_desc');

    document.querySelectorAll('.card-info-btn').forEach(btn => {
      btn.textContent = t('btn_learn_more');
    });

    const safetyBox = document.querySelector('.safety-banner, .safety-protocol, .safety-warning');
    if (safetyBox) safetyBox.textContent = t('safety_protocol');

    const btnStart = document.getElementById('btnStartWorkbench');
    if (btnStart) btnStart.textContent = t('btn_enter_apparatus');

    // 5. Stage 2: Apparatus
    const s2Tag = document.querySelector('#stage2 .stage-tag');
    if (s2Tag) s2Tag.textContent = t('stage2_tag');
    const s2Title = document.querySelector('#stage2 h2');
    if (s2Title) s2Title.textContent = t('stage2_title');
    const s2Sub = document.querySelector('#stage2 .concept-subtitle');
    if (s2Sub) s2Sub.textContent = t('stage2_subtitle');
    const btnProcReagents = document.getElementById('btnProceedToReagents');
    if (btnProcReagents) btnProcReagents.textContent = t('btn_proceed_reagents');

    // 6. Stage 3: Reagents
    const s3Tag = document.querySelector('#stage3 .stage-tag');
    if (s3Tag) s3Tag.textContent = t('stage3_tag');
    const s3Title = document.querySelector('#stage3 h2');
    if (s3Title) s3Title.textContent = t('stage3_title');
    const s3Sub = document.querySelector('#stage3 .concept-subtitle');
    if (s3Sub) s3Sub.textContent = t('stage3_subtitle');
    const btnProcExp = document.getElementById('btnProceedToExperiment');
    if (btnProcExp) btnProcExp.textContent = t('btn_enter_workbench');

    // 7. Stage 4: Experiment Controls
    const s4Tag = document.querySelector('#stage4 .stage-tag');
    if (s4Tag) s4Tag.textContent = t('stage4_tag');
    const s4Title = document.querySelector('#stage4 h2');
    if (s4Title) s4Title.textContent = t('stage4_title');
    const s4Sub = document.querySelector('#stage4 .concept-subtitle');
    if (s4Sub) s4Sub.textContent = t('stage4_subtitle');

    const btnAddAnalyte = document.getElementById('btnAddAnalyte');
    if (btnAddAnalyte) btnAddAnalyte.textContent = t('btn_add_analyte');
    const btnAddIndicator = document.getElementById('btnAddIndicator');
    if (btnAddIndicator) btnAddIndicator.textContent = t('btn_add_indicator');
    const btnFillBurette = document.getElementById('btnFillBurette');
    if (btnFillBurette) btnFillBurette.textContent = t('btn_fill_burette');

    const btnStopValve = document.getElementById('btnStopValve');
    if (btnStopValve) btnStopValve.textContent = t('btn_stop_valve');
    const btnSlowDrip = document.getElementById('btnSlowDrip');
    if (btnSlowDrip) btnSlowDrip.textContent = t('btn_slow_drip');
    const btnFastFlow = document.getElementById('btnFastFlow');
    if (btnFastFlow) btnFastFlow.textContent = t('btn_fast_flow');
    const btnResetExp = document.getElementById('btnResetTitration');
    if (btnResetExp) btnResetExp.textContent = t('btn_reset_exp');
    const btnFinishExp = document.getElementById('btnFinishExperiment');
    if (btnFinishExp) btnFinishExp.textContent = t('btn_generate_report');

    // 8. Stage 5: Report
    const s5Tag = document.querySelector('#stage5 .stage-tag');
    if (s5Tag) s5Tag.textContent = t('stage5_tag');
    const reportHeading = document.getElementById('reportTitle');
    if (reportHeading) reportHeading.textContent = t('report_title');
    const btnDone = document.getElementById('btnDoneLab');
    if (btnDone) btnDone.textContent = t('btn_return_roadmap');
  }

  // Expose globally
  window.VirtualLabI18n = {
    t: t,
    getLanguage: () => currentLang,
    setLanguage: applyLanguage,
    init: () => {
      currentLang = resolveLanguage();
      applyLanguage(currentLang);
    }
  };

  // Auto-listen to window messages
  window.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'SET_LANGUAGE' && event.data.lang) {
      applyLanguage(event.data.lang);
    }
  });

  // Apply on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => window.VirtualLabI18n.init());
  } else {
    window.VirtualLabI18n.init();
  }
})();
