/* =========================================================
   ZUNO VIRTUAL CHEMISTRY LAB
   STAGE 1 + STAGE 2 + STAGE 3 + STAGE 4 + STAGE 5
========================================================= */

function sendQuestlyEvent(eventType, payload) {
    try {
        if (window.parent && window.parent !== window) {
            window.parent.postMessage({
                type: 'QUESTLY_LAB_EVENT',
                event: eventType,
                ...payload
            }, '*');
        }
    } catch (e) {
        console.log('Questly bridge error:', e);
    }
}

/* =========================================================
   STAGE 1
   APPARATUS SELECTION
========================================================= */

const requiredApparatus = [
    "Conical Flask",
    "Pipette",
    "Burette",
    "Beaker"
];

const apparatus = [
    {
        name: "Conical Flask",
        icon: "⚗️"
    },
    {
        name: "Pipette",
        icon: "🧪"
    },
    {
        name: "Burette",
        icon: "📏"
    },
    {
        name: "Beaker",
        icon: "🥛"
    },
    {
        name: "Test Tube",
        icon: "🧫"
    },
    {
        name: "Measuring Cylinder",
        icon: "📐"
    },
    {
        name: "Funnel",
        icon: "🔻"
    },
    {
        name: "Tripod Stand",
        icon: "🔺"
    }
];


/* =========================================================
   HTML ELEMENTS
========================================================= */

const apparatusContainer =
    document.getElementById("apparatusContainer");

const requiredList =
    document.getElementById("requiredList");

const feedback =
    document.getElementById("feedback");

const nextButton =
    document.getElementById("nextButton");

const successPopup =
    document.getElementById("successPopup");

const continueButton =
    document.getElementById("continueButton");


/* =========================================================
   STAGE 1 VARIABLES
========================================================= */

let selectedApparatus = [];


/* =========================================================
   DISPLAY REQUIRED APPARATUS
========================================================= */

function displayRequiredApparatus() {

    if (!requiredList) {
        return;
    }

    requiredList.innerHTML = "";

    requiredApparatus.forEach(function(item) {

        const element =
            document.createElement("div");

        element.className =
            "required-item";

        element.id =
            "required-" +
            item.replaceAll(" ", "-");

        element.textContent =
            "○ " + item;

        requiredList.appendChild(element);

    });
}


/* =========================================================
   DISPLAY APPARATUS
========================================================= */

function displayApparatus() {

    if (!apparatusContainer) {
        return;
    }

    apparatusContainer.innerHTML = "";

    apparatus.forEach(function(item) {

        const card =
            document.createElement("div");

        card.className =
            "apparatus";

        card.dataset.name =
            item.name;


        const icon =
            document.createElement("div");

        icon.className =
            "apparatus-icon";

        icon.textContent =
            item.icon;


        const name =
            document.createElement("div");

        name.className =
            "apparatus-name";

        name.textContent =
            item.name;


        card.appendChild(icon);
        card.appendChild(name);


        card.addEventListener(
            "pointerup",
            function(event) {

                event.preventDefault();

                selectApparatus(
                    item.name,
                    card
                );

            }
        );


        apparatusContainer.appendChild(card);

    });
}


/* =========================================================
   SELECT APPARATUS
========================================================= */

function selectApparatus(name, card) {

    if (selectedApparatus.includes(name)) {

        showFeedback(
            "You already selected " + name + ".",
            "correct"
        );

        return;
    }


    if (requiredApparatus.includes(name)) {

        selectedApparatus.push(name);

        card.classList.remove("wrong");
        card.classList.add("correct");


        const requiredItem =
            document.getElementById(
                "required-" +
                name.replaceAll(" ", "-")
            );


        if (requiredItem) {

            requiredItem.classList.add("selected");

            requiredItem.textContent =
                "✓ " + name;

        }


        showFeedback(
            "Correct! " +
            name +
            " is required.",
            "correct"
        );


        checkStage1Completion();

    }

    else {

        card.classList.add("wrong");

        showFeedback(
            "Wrong apparatus! " +
            name +
            " is not required.",
            "wrong"
        );


        setTimeout(function() {

            card.classList.remove("wrong");

        }, 700);

    }
}


/* =========================================================
   GENERAL FEEDBACK
========================================================= */

function showFeedback(message, type) {

    if (!feedback) {
        return;
    }

    feedback.classList.remove(
        "hidden",
        "correct-feedback",
        "wrong-feedback"
    );


    if (type === "correct") {

        feedback.classList.add(
            "correct-feedback"
        );

    }
    else {

        feedback.classList.add(
            "wrong-feedback"
        );

    }


    feedback.textContent =
        message;


    setTimeout(function() {

        feedback.classList.add("hidden");

    }, 2500);
}


/* =========================================================
   STAGE 1 COMPLETION
========================================================= */

function checkStage1Completion() {

    if (
        selectedApparatus.length ===
        requiredApparatus.length
    ) {

        if (nextButton) {

            nextButton.disabled = false;

            nextButton.classList.remove(
                "disabled"
            );

        }


        showFeedback(
            "Excellent! All required apparatus selected.",
            "correct"
        );
    }
}


/* =========================================================
   STAGE 1 NEXT BUTTON
========================================================= */

if (nextButton) {

    nextButton.addEventListener(
        "click",
        function() {

            if (
                selectedApparatus.length ===
                requiredApparatus.length
            ) {

                sendQuestlyEvent('stage_complete', { stage: 1, step: 'Apparatus Selection' });

                if (successPopup) {

                    successPopup.classList.remove(
                        "hidden"
                    );

                }
            }

        }
    );
}


/* =========================================================
   STAGE 1 → STAGE 2
========================================================= */

if (continueButton) {

    continueButton.addEventListener(
        "click",
        function() {

            if (successPopup) {

                successPopup.classList.add(
                    "hidden"
                );

            }


            const bottomSection =
                document.querySelector(
                    ".bottom-section"
                );


            if (bottomSection) {

                bottomSection.classList.add(
                    "hidden"
                );

            }


            const stage2 =
                document.getElementById(
                    "stage2-section"
                );


            if (stage2) {

                stage2.classList.remove(
                    "hidden"
                );

            }


            initializeStage2();

        }
    );
}


/* =========================================================
   STAGE 2
   SOLUTION SELECTION
========================================================= */

const requiredStage2Reagents = [
    "acid-bottle",
    "base-bottle",
    "indicator-bottle"
];

let selectedCorrectReagents = new Set();

let stage2Initialized = false;


/* =========================================================
   INITIALIZE STAGE 2
========================================================= */

function initializeStage2() {

    if (stage2Initialized) {
        return;
    }

    stage2Initialized = true;


    const bottles =
        document.querySelectorAll(
            ".lab-glass-bottle"
        );


    bottles.forEach(function(bottle) {

        bottle.setAttribute(
            "draggable",
            "false"
        );

        bottle.style.touchAction =
            "manipulation";


        bottle.addEventListener(
            "pointerup",
            function(event) {

                event.preventDefault();

                selectStage2Solution(
                    bottle
                );

            }
        );

    });
}


/* =========================================================
   SELECT STAGE 2 SOLUTION
========================================================= */

function selectStage2Solution(bottle) {

    const bottleId =
        bottle.id
            .trim()
            .toLowerCase();


    if (
        selectedCorrectReagents.has(
            bottleId
        )
    ) {

        showStage2Message(
            "You already selected this solution.",
            "correct"
        );

        return;
    }


    removeBottleStatus(bottle);


    if (
        requiredStage2Reagents.includes(
            bottleId
        )
    ) {

        selectedCorrectReagents.add(
            bottleId
        );


        showBottleStatus(
            bottle,
            "correct"
        );


        bottle.classList.add(
            "solution-correct"
        );


        showStage2Message(
            "Correct! This solution is required.",
            "correct"
        );


        checkStage2Completion();

    }

    else {

        showBottleStatus(
            bottle,
            "wrong"
        );


        bottle.classList.add(
            "solution-wrong"
        );


        showStage2Message(
            "Wrong solution! This solution is not required.",
            "wrong"
        );


        setTimeout(function() {

            bottle.classList.remove(
                "solution-wrong"
            );

            removeBottleStatus(bottle);

        }, 1500);
    }
}


/* =========================================================
   BOTTLE STATUS
========================================================= */

function showBottleStatus(bottle, status) {

    removeBottleStatus(bottle);


    const overlay =
        document.createElement("div");


    overlay.className =
        "bottle-status-overlay";


    overlay.textContent =
        status === "correct"
            ? "✅"
            : "❌";


    overlay.style.position =
        "absolute";

    overlay.style.top =
        "50%";

    overlay.style.left =
        "50%";

    overlay.style.transform =
        "translate(-50%, -50%)";

    overlay.style.fontSize =
        "40px";

    overlay.style.zIndex =
        "1000";

    overlay.style.pointerEvents =
        "none";


    bottle.appendChild(overlay);
}


/* =========================================================
   REMOVE BOTTLE STATUS
========================================================= */

function removeBottleStatus(bottle) {

    const oldStatus =
        bottle.querySelector(
            ".bottle-status-overlay"
        );


    if (oldStatus) {
        oldStatus.remove();
    }
}


/* =========================================================
   STAGE 2 FEEDBACK
========================================================= */

function showStage2Message(message, type) {

    if (!feedback) {
        return;
    }


    feedback.classList.remove(
        "hidden",
        "correct-feedback",
        "wrong-feedback"
    );


    if (type === "correct") {

        feedback.classList.add(
            "correct-feedback"
        );

    }
    else {

        feedback.classList.add(
            "wrong-feedback"
        );

    }


    feedback.textContent =
        message;


    setTimeout(function() {

        feedback.classList.add(
            "hidden"
        );

    }, 2500);
}


/* =========================================================
   STAGE 2 COMPLETION
========================================================= */

function checkStage2Completion() {

    if (
        selectedCorrectReagents.size !==
        requiredStage2Reagents.length
    ) {
        return;
    }


    const dropZone =
        document.getElementById(
            "table-drop-zone"
        );


    if (dropZone) {

        if (
            document.getElementById(
                "stage2-next-container"
            )
        ) {
            return;
        }


        dropZone.innerHTML = `

            <div id="stage2-next-container">

                <p>
                    🎉 Excellent!
                    All required solutions selected.
                </p>

                <button id="stage2-next-btn">
                    Go to Stage 3 →
                </button>

            </div>

        `;


        const button =
            document.getElementById(
                "stage2-next-btn"
            );


        if (button) {

            button.addEventListener(
                "click",
                goToStage3
            );

        }
    }

    else {

        createStage2Completion();

    }
}


/* =========================================================
   STAGE 2 FALLBACK COMPLETION
========================================================= */

function createStage2Completion() {

    const stage2 =
        document.getElementById(
            "stage2-section"
        );


    if (!stage2) {
        return;
    }


    if (
        document.getElementById(
            "stage2-next-container"
        )
    ) {
        return;
    }


    const box =
        document.createElement("div");


    box.id =
        "stage2-next-container";


    box.innerHTML = `

        <p>
            🎉 Excellent!
            All required solutions selected.
        </p>

        <button id="stage2-next-btn">
            Go to Stage 3 →
        </button>

    `;


    stage2.appendChild(box);


    const button =
        document.getElementById(
            "stage2-next-btn"
        );


    if (button) {

        button.addEventListener(
            "click",
            goToStage3
        );

    }
}


/* =========================================================
   STAGE 3
   MEASURING & PIPETTE SETUP
========================================================= */

let stage3Selected = [];

const stage3Required = [
    "pipette",
    "flask",
    "solution"
];


/* =========================================================
   GO TO STAGE 3
========================================================= */

function goToStage3() {

    sendQuestlyEvent('stage_complete', { stage: 2, step: 'Solutions Preparation' });

    const stage2 =
        document.getElementById(
            "stage2-section"
        );


    if (stage2) {

        stage2.classList.add(
            "hidden"
        );

    }


    let stage3 =
        document.getElementById(
            "stage3-section"
        );


    if (!stage3) {

        stage3 =
            document.createElement(
                "section"
            );

        stage3.id =
            "stage3-section";

        stage3.className =
            "stage3-section";


        document.body.appendChild(
            stage3
        );
    }


    stage3.classList.remove(
        "hidden"
    );


    initializeStage3();
}


/* =========================================================
   INITIALIZE STAGE 3
========================================================= */

function initializeStage3() {

    stage3Selected = [];


    const stage3 =
        document.getElementById(
            "stage3-section"
        );


    if (!stage3) {
        return;
    }


    stage3.innerHTML = `

        <div class="stage3-header">

            <h2>
                🧪 Stage 3: Measuring & Pipette Setup
            </h2>

            <p>
                Select the correct equipment and
                solution for the titration.
            </p>

        </div>


        <div class="stage3-required">

            <h3>
                Required for this step
            </h3>


            <div class="stage3-required-list">

                <span
                    id="stage3-pipette-required"
                    class="stage3-required-item"
                >
                    ○ Pipette
                </span>


                <span
                    id="stage3-flask-required"
                    class="stage3-required-item"
                >
                    ○ Conical Flask
                </span>


                <span
                    id="stage3-solution-required"
                    class="stage3-required-item"
                >
                    ○ Solution
                </span>

            </div>

        </div>


        <div class="stage3-lab">

            <div class="stage3-title">
                🔬 Measuring Station
            </div>


            <div class="stage3-equipment-container">

                <div
                    class="stage3-equipment"
                    data-stage3="pipette"
                >

                    <div class="stage3-icon">
                        🧪
                    </div>

                    <div class="stage3-name">
                        Pipette
                    </div>

                </div>


                <div
                    class="stage3-equipment"
                    data-stage3="flask"
                >

                    <div class="stage3-icon">
                        ⚗️
                    </div>

                    <div class="stage3-name">
                        Conical Flask
                    </div>

                </div>


                <div
                    class="stage3-equipment"
                    data-stage3="testtube"
                >

                    <div class="stage3-icon">
                        🧫
                    </div>

                    <div class="stage3-name">
                        Test Tube
                    </div>

                </div>


                <div
                    class="stage3-equipment"
                    data-stage3="solution"
                >

                    <div class="stage3-icon">
                        🧴
                    </div>

                    <div class="stage3-name">
                        Selected Solution
                    </div>

                </div>

            </div>


            <div
                id="stage3-feedback"
                class="stage3-feedback hidden"
            ></div>


            <div
                id="stage3-action-area"
                class="stage3-action-area"
            >

                <p>
                    🧪 Select the Pipette first.
                </p>

            </div>

        </div>

    `;


    setupStage3Equipment();
}


/* =========================================================
   STAGE 3 EQUIPMENT EVENTS
========================================================= */

function setupStage3Equipment() {

    const equipment =
        document.querySelectorAll(
            ".stage3-equipment"
        );


    equipment.forEach(function(item) {

        item.addEventListener(
            "pointerup",
            function(event) {

                event.preventDefault();

                selectStage3Equipment(
                    item.dataset.stage3,
                    item
                );

            }
        );

    });
}


/* =========================================================
   SELECT STAGE 3 EQUIPMENT
========================================================= */

function selectStage3Equipment(type, element) {

    if (
        stage3Selected.includes(type)
    ) {

        showStage3Feedback(
            "You already selected this item.",
            "correct"
        );

        return;
    }


    if (
        stage3Required.includes(type)
    ) {

        stage3Selected.push(type);


        element.classList.add(
            "stage3-correct"
        );


        updateStage3RequiredList(type);


        showStage3Feedback(
            "Correct! " +
            getStage3Name(type) +
            " is required.",
            "correct"
        );


        checkStage3Progress();

    }

    else {

        element.classList.add(
            "stage3-wrong"
        );


        showStage3Feedback(
            "Wrong equipment! " +
            getStage3Name(type) +
            " is not required.",
            "wrong"
        );


        setTimeout(function() {

            element.classList.remove(
                "stage3-wrong"
            );

        }, 700);

    }
}


/* =========================================================
   STAGE 3 NAME
========================================================= */

function getStage3Name(type) {

    const names = {

        pipette:
            "Pipette",

        flask:
            "Conical Flask",

        solution:
            "Selected Solution",

        testtube:
            "Test Tube"

    };


    return names[type] || type;
}


/* =========================================================
   UPDATE STAGE 3 REQUIRED LIST
========================================================= */

function updateStage3RequiredList(type) {

    let id = "";


    if (type === "pipette") {

        id =
            "stage3-pipette-required";

    }

    else if (type === "flask") {

        id =
            "stage3-flask-required";

    }

    else if (type === "solution") {

        id =
            "stage3-solution-required";

    }


    const item =
        document.getElementById(id);


    if (item) {

        item.classList.add(
            "selected"
        );

        item.textContent =
            "✓ " +
            getStage3Name(type);

    }
}


/* =========================================================
   CHECK STAGE 3 PROGRESS
========================================================= */

function checkStage3Progress() {

    if (
        stage3Selected.length !==
        stage3Required.length
    ) {

        updateStage3Instruction();

        return;
    }


    showStage3Feedback(
        "Excellent! All required items selected.",
        "correct"
    );


    showStage3MeasuringStep();
}


/* =========================================================
   STAGE 3 INSTRUCTION
========================================================= */

function updateStage3Instruction() {

    const area =
        document.getElementById(
            "stage3-action-area"
        );


    if (!area) {
        return;
    }


    if (
        !stage3Selected.includes(
            "pipette"
        )
    ) {

        area.innerHTML = `
            <p>
                🧪 Select the Pipette first.
            </p>
        `;

        return;
    }


    if (
        !stage3Selected.includes(
            "flask"
        )
    ) {

        area.innerHTML = `
            <p>
                ⚗️ Good!
                Now select the Conical Flask.
            </p>
        `;

        return;
    }


    if (
        !stage3Selected.includes(
            "solution"
        )
    ) {

        area.innerHTML = `
            <p>
                🧴 Now select the required solution.
            </p>
        `;
    }
}


/* =========================================================
   STAGE 3 FEEDBACK
========================================================= */

function showStage3Feedback(message, type) {

    const feedbackBox =
        document.getElementById(
            "stage3-feedback"
        );


    if (!feedbackBox) {
        return;
    }


    feedbackBox.classList.remove(
        "hidden",
        "stage3-feedback-correct",
        "stage3-feedback-wrong"
    );


    if (type === "correct") {

        feedbackBox.classList.add(
            "stage3-feedback-correct"
        );

    }
    else {

        feedbackBox.classList.add(
            "stage3-feedback-wrong"
        );

    }


    feedbackBox.textContent =
        message;


    setTimeout(function() {

        feedbackBox.classList.add(
            "hidden"
        );

    }, 2500);
}


/* =========================================================
   SHOW MEASURING STEP
========================================================= */

function showStage3MeasuringStep() {

    const area =
        document.getElementById(
            "stage3-action-area"
        );


    if (!area) {
        return;
    }


    area.innerHTML = `

        <div class="measuring-card">

            <div class="measuring-icon">
                🧪
            </div>

            <h3>
                Ready for Measuring!
            </h3>

            <p>
                All required equipment and
                solution are ready.
            </p>


            <button
                id="start-measuring-btn"
                class="stage3-action-button"
            >
                Start Measuring →
            </button>

        </div>

    `;


    const button =
        document.getElementById(
            "start-measuring-btn"
        );


    if (button) {

        button.addEventListener(
            "click",
            startMeasuring
        );

    }
}


/* =========================================================
   START MEASURING
========================================================= */

function startMeasuring() {

    const area =
        document.getElementById(
            "stage3-action-area"
        );


    if (!area) {
        return;
    }


    area.innerHTML = `

        <div class="measuring-card">

            <div class="measuring-icon">
                💧
            </div>

            <h3>
                Measuring the Solution
            </h3>

            <p>
                Choose the correct volume
                for the pipette.
            </p>


            <div class="volume-options">

                <button
                    class="volume-option"
                    data-volume="5"
                >
                    5 mL
                </button>


                <button
                    class="volume-option"
                    data-volume="10"
                >
                    10 mL
                </button>


                <button
                    class="volume-option"
                    data-volume="25"
                >
                    25 mL
                </button>

            </div>


            <div
                id="volume-feedback"
                class="volume-feedback hidden"
            ></div>

        </div>

    `;


    setupVolumeButtons();
}


/* =========================================================
   VOLUME BUTTONS
========================================================= */

function setupVolumeButtons() {

    const buttons =
        document.querySelectorAll(
            ".volume-option"
        );


    buttons.forEach(function(button) {

        button.addEventListener(
            "click",
            function() {

                checkVolume(
                    button.dataset.volume,
                    button
                );

            }
        );

    });
}


/* =========================================================
   CHECK VOLUME
========================================================= */

function checkVolume(volume, button) {

    const correctVolume =
        "10";


    if (volume === correctVolume) {

        button.classList.add(
            "volume-correct"
        );


        showVolumeFeedback(
            "Correct! 10 mL is the required volume.",
            "correct"
        );


        showStage3Complete();

    }

    else {

        button.classList.add(
            "volume-wrong"
        );


        showVolumeFeedback(
            "Incorrect volume. Try again.",
            "wrong"
        );


        setTimeout(function() {

            button.classList.remove(
                "volume-wrong"
            );

        }, 700);

    }
}


/* =========================================================
   VOLUME FEEDBACK
========================================================= */

function showVolumeFeedback(message, type) {

    const feedbackBox =
        document.getElementById(
            "volume-feedback"
        );


    if (!feedbackBox) {
        return;
    }


    feedbackBox.classList.remove(
        "hidden",
        "volume-feedback-correct",
        "volume-feedback-wrong"
    );


    if (type === "correct") {

        feedbackBox.classList.add(
            "volume-feedback-correct"
        );

    }
    else {

        feedbackBox.classList.add(
            "volume-feedback-wrong"
        );

    }


    feedbackBox.textContent =
        message;
}


/* =========================================================
   STAGE 3 COMPLETE
========================================================= */

function showStage3Complete() {

    sendQuestlyEvent('stage_complete', { stage: 3, step: 'Pipette & Flask Setup' });

    const area =
        document.getElementById(
            "stage3-action-area"
        );


    if (!area) {
        return;
    }


    area.innerHTML = `

        <div class="stage3-complete-card">

            <div class="stage3-complete-icon">
                ✓
            </div>

            <h2>
                Stage 3 Complete!
            </h2>

            <p>
                You correctly selected the equipment
                and measured the required solution.
            </p>


            <button
                id="stage3-next-btn"
                class="stage3-action-button"
            >
                Continue to Stage 4 →
            </button>

        </div>

    `;


    const button =
        document.getElementById(
            "stage3-next-btn"
        );


    if (button) {

        button.addEventListener(
            "click",
            showStage4
        );

    }
}


/* =========================================================
   STAGE 4
   TITRATION REACTION
========================================================= */

let stage4Started = false;

let stage4Drops = 0;

const stage4RequiredDrops = 8;


/* =========================================================
   GO TO STAGE 4
========================================================= */

function showStage4() {

    initializeStage4();
}


/* =========================================================
   INITIALIZE STAGE 4
========================================================= */

function initializeStage4() {

    const stage2 =
        document.getElementById(
            "stage2-section"
        );


    const stage3 =
        document.getElementById(
            "stage3-section"
        );


    const stage4 =
        document.getElementById(
            "stage4-section"
        );


    if (stage2) {

        stage2.classList.add(
            "hidden"
        );

    }


    if (stage3) {

        stage3.classList.add(
            "hidden"
        );

    }


    if (!stage4) {

        console.error(
            "Stage 4 section not found in HTML."
        );

        return;
    }


    stage4.classList.remove(
        "hidden"
    );


    stage4Started = false;

    stage4Drops = 0;


    /* RESET COUNTER */

    const dropCount =
        document.getElementById(
            "drop-count"
        );


    if (dropCount) {

        dropCount.textContent =
            "0 / " +
            stage4RequiredDrops;

    }


    /* RESET FLASK */

    const liquid =
        document.getElementById(
            "flask-liquid"
        );


    if (liquid) {

        liquid.style.background =
            "#f8c8dc";

    }


    /* RESET INDICATOR */

    const status =
        document.getElementById(
            "indicator-status"
        );


    if (status) {

        status.textContent =
            "Indicator: Ready";

        status.classList.remove(
            "endpoint-reached"
        );

    }


    /* RESET DROP */

    const drop =
        document.getElementById(
            "solution-drop"
        );


    if (drop) {

        drop.classList.add(
            "hidden"
        );

    }


    /* RESET ACTION AREA */

    const actionArea =
        document.getElementById(
            "stage4-action-area"
        );


    if (actionArea) {

        actionArea.innerHTML = `

            <p>
                The apparatus is ready for titration.
            </p>

            <button
                id="start-titration-btn"
                class="stage4-button"
            >
                ▶ Start Titration
            </button>

        `;

    }


    setupStage4();
}


/* =========================================================
   SETUP STAGE 4
========================================================= */

function setupStage4() {

    const startButton =
        document.getElementById(
            "start-titration-btn"
        );


    if (startButton) {

        startButton.addEventListener(
            "click",
            startTitration
        );

    }
}


/* =========================================================
   START TITRATION
========================================================= */

function startTitration() {

    if (stage4Started) {
        return;
    }


    stage4Started = true;


    const actionArea =
        document.getElementById(
            "stage4-action-area"
        );


    if (!actionArea) {
        return;
    }


    actionArea.innerHTML = `

        <p class="titration-instruction">
            💧 Add the solution drop by drop.
        </p>


        <button
            id="add-drop-btn"
            class="stage4-button"
        >
            💧 Add Solution
        </button>

    `;


    const addButton =
        document.getElementById(
            "add-drop-btn"
        );


    if (addButton) {

        addButton.addEventListener(
            "click",
            addTitrationDrop
        );

    }


    showStage4Feedback(
        "Titration started! Add the solution slowly.",
        "correct"
    );
}


/* =========================================================
   ADD TITRATION DROP
========================================================= */

function addTitrationDrop() {

    if (!stage4Started) {
        return;
    }


    if (
        stage4Drops >=
        stage4RequiredDrops
    ) {
        return;
    }


    stage4Drops++;


    updateStage4Counter();

    animateDrop();

    updateFlaskColour();


    if (
        stage4Drops ===
        stage4RequiredDrops
    ) {

        const addButton =
            document.getElementById(
                "add-drop-btn"
            );


        if (addButton) {

            addButton.disabled =
                true;

            addButton.textContent =
                "✓ Endpoint Reached";

        }


        setTimeout(
            showTitrationEndpoint,
            700
        );
    }
}


/* =========================================================
   UPDATE COUNTER
========================================================= */

function updateStage4Counter() {

    const counter =
        document.getElementById(
            "drop-count"
        );


    if (counter) {

        counter.textContent =
            stage4Drops +
            " / " +
            stage4RequiredDrops;

    }
}


/* =========================================================
   DROP ANIMATION
========================================================= */

function animateDrop() {

    const drop =
        document.getElementById(
            "solution-drop"
        );


    if (!drop) {
        return;
    }


    drop.classList.remove(
        "hidden"
    );


    drop.classList.remove(
        "drop-animation"
    );


    void drop.offsetWidth;


    drop.classList.add(
        "drop-animation"
    );


    setTimeout(function() {

        drop.classList.add(
            "hidden"
        );

    }, 650);
}


/* =========================================================
   UPDATE FLASK COLOUR
========================================================= */

function updateFlaskColour() {

    const liquid =
        document.getElementById(
            "flask-liquid"
        );


    const status =
        document.getElementById(
            "indicator-status"
        );


    if (!liquid) {
        return;
    }


    const progress =
        stage4Drops /
        stage4RequiredDrops;


    if (progress < 0.35) {

        liquid.style.background =
            "#f8c8dc";

    }

    else if (progress < 0.70) {

        liquid.style.background =
            "#f39ac0";

    }

    else if (progress < 1) {

        liquid.style.background =
            "#ef6fa8";

    }

    else {

        liquid.style.background =
            "#d81b60";

    }


    if (status) {

        status.textContent =
            "Indicator: Reacting...";

    }
}


/* =========================================================
   TITRATION ENDPOINT
========================================================= */

function showTitrationEndpoint() {

    const status =
        document.getElementById(
            "indicator-status"
        );


    if (status) {

        status.textContent =
            "Indicator: ENDPOINT REACHED ✓";

        status.classList.add(
            "endpoint-reached"
        );

    }


    showStage4Feedback(
        "🎉 Endpoint reached! The indicator changed colour.",
        "correct"
    );


    showStage4Complete();
}


/* =========================================================
   STAGE 4 FEEDBACK
========================================================= */

function showStage4Feedback(message, type) {

    const feedbackBox =
        document.getElementById(
            "stage4-feedback"
        );


    if (!feedbackBox) {
        return;
    }


    feedbackBox.classList.remove(
        "hidden",
        "stage4-feedback-correct",
        "stage4-feedback-wrong"
    );


    if (type === "correct") {

        feedbackBox.classList.add(
            "stage4-feedback-correct"
        );

    }

    else {

        feedbackBox.classList.add(
            "stage4-feedback-wrong"
        );

    }


    feedbackBox.textContent =
        message;
}


/* =========================================================
   STAGE 4 COMPLETE
========================================================= */

function showStage4Complete() {

    sendQuestlyEvent('stage_complete', { stage: 4, step: 'Titration Endpoint' });

    const actionArea =
        document.getElementById(
            "stage4-action-area"
        );


    if (!actionArea) {
        return;
    }


    actionArea.innerHTML = `

        <div class="stage4-complete-card">

            <div class="stage4-complete-icon">
                🎉
            </div>


            <h2>
                Stage 4 Complete!
            </h2>


            <p>
                Excellent! You successfully performed
                the titration and reached the endpoint.
            </p>


            <div class="result-box">

                <strong>
                    🧪 Titration Result
                </strong>


                <p>
                    Solution added:
                    <b>8 drops</b>
                </p>


                <p>
                    Endpoint:
                    <b>Reached ✓</b>
                </p>


                <p>
                    Indicator:
                    <b>Colour changed ✓</b>
                </p>

            </div>


            <button
                id="stage4-next-btn"
                class="stage4-button"
            >
                Continue to Stage 5 →
            </button>

        </div>

    `;


    const nextButton =
        document.getElementById(
            "stage4-next-btn"
        );


    if (nextButton) {

        nextButton.addEventListener(
            "click",
            showStage5
        );

    }
}


/* =========================================================
   STAGE 5
   FINAL EXPERIMENT RESULT
========================================================= */

function showStage5() {

    const stage4 =
        document.getElementById(
            "stage4-section"
        );


    const stage5 =
        document.getElementById(
            "stage5-section"
        );


    /* HIDE STAGE 4 */

    if (stage4) {

        stage4.classList.add(
            "hidden"
        );

    }


    /* SHOW STAGE 5 */

    if (!stage5) {

        console.error(
            "Stage 5 section not found in HTML."
        );

        return;
    }


    stage5.classList.remove(
        "hidden"
    );


    initializeStage5();


    window.scrollTo({
        top: 0,
        behavior: "smooth"
    });
}


/* =========================================================
   INITIALIZE STAGE 5
========================================================= */

function initializeStage5() {

    sendQuestlyEvent('lab_complete', { stage: 5, score: 100 });

    const score =
        document.getElementById(
            "stage5-score"
        );


    if (score) {

        score.textContent =
            "100%";

    }


    const restartButton =
        document.getElementById(
            "stage5-restart-btn"
        );


    if (restartButton) {

        restartButton.onclick =
            restartExperiment;

    }

    const roadmapButton =
        document.getElementById(
            "stage5-roadmap-btn"
        );

    if (roadmapButton) {

        roadmapButton.onclick =
            function() {
                sendQuestlyEvent('navigate_back', {});
            };

    }
}


/* =========================================================
   RESTART EXPERIMENT
========================================================= */

function restartExperiment() {

    /* -----------------------------------------
       RESET STAGE 1
    ----------------------------------------- */

    selectedApparatus = [];


    if (nextButton) {

        nextButton.disabled =
            true;

        nextButton.classList.add(
            "disabled"
        );

    }


    /* -----------------------------------------
       RESET STAGE 2
    ----------------------------------------- */

    selectedCorrectReagents =
        new Set();

    stage2Initialized =
        false;


    /* -----------------------------------------
       RESET STAGE 3
    ----------------------------------------- */

    stage3Selected = [];


    /* -----------------------------------------
       RESET STAGE 4
    ----------------------------------------- */

    stage4Started =
        false;

    stage4Drops =
        0;


    /* -----------------------------------------
       HIDE STAGE 5
    ----------------------------------------- */

    const stage5 =
        document.getElementById(
            "stage5-section"
        );


    if (stage5) {

        stage5.classList.add(
            "hidden"
        );

    }


    /* -----------------------------------------
       HIDE STAGE 4
    ----------------------------------------- */

    const stage4 =
        document.getElementById(
            "stage4-section"
        );


    if (stage4) {

        stage4.classList.add(
            "hidden"
        );

    }


    /* -----------------------------------------
       HIDE STAGE 3
    ----------------------------------------- */

    const stage3 =
        document.getElementById(
            "stage3-section"
        );


    if (stage3) {

        stage3.classList.add(
            "hidden"
        );

    }


    /* -----------------------------------------
       HIDE STAGE 2
    ----------------------------------------- */

    const stage2 =
        document.getElementById(
            "stage2-section"
        );


    if (stage2) {

        stage2.classList.add(
            "hidden"
        );

    }


    /* -----------------------------------------
       SHOW STAGE 1
    ----------------------------------------- */

    const bottomSection =
        document.querySelector(
            ".bottom-section"
        );


    if (bottomSection) {

        bottomSection.classList.remove(
            "hidden"
        );

    }


    /* -----------------------------------------
       RESET REQUIRED LIST
    ----------------------------------------- */

    displayRequiredApparatus();


    /* -----------------------------------------
       RESET APPARATUS CARDS
    ----------------------------------------- */

    displayApparatus();


    /* -----------------------------------------
       CLOSE POPUP
    ----------------------------------------- */

    if (successPopup) {

        successPopup.classList.add(
            "hidden"
        );

    }


    /* -----------------------------------------
       SCROLL TO TOP
    ----------------------------------------- */

    window.scrollTo({
        top: 0,
        behavior: "smooth"
    });


    showFeedback(
        "Experiment restarted. Let's begin again! 🧪",
        "correct"
    );
}


/* =========================================================
   APPLICATION START
========================================================= */

displayRequiredApparatus();

displayApparatus();


/* =========================================================
   AUTO INITIALIZE STAGE 2
========================================================= */

const initialStage2 =
    document.getElementById(
        "stage2-section"
    );


if (
    initialStage2 &&
    !initialStage2.classList.contains(
        "hidden"
    )
) {

    initializeStage2();

}


/* =========================================================
   END OF ZUNO VIRTUAL CHEMISTRY LAB
========================================================= */