'use strict';
const langSwitch = document.querySelector('.lang-switch');
const allLang = ['ru', 'en'];

location.href = window.location.pathname + '#ru';
changeLanguage();

langSwitch.addEventListener('click', btnLanguageSwitcher);
langSwitch.addEventListener('click', changeUrlLang);

function btnLanguageSwitcher() {
    if (langSwitch.textContent === 'Русский') {
        langSwitch.textContent = 'English';
        langSwitch.value = 'ru';
        
    } else if (langSwitch.textContent === 'English'){
        langSwitch.textContent = 'Русский';
        langSwitch.value = 'en';
    }
}

function changeUrlLang() {
    let lang = langSwitch.value;
    location.href = window.location.pathname + '#' + lang;
    changeLanguage();
}

function changeLanguage() {
    let hash = window.location.hash;
    hash = hash.slice(1);
    if (!allLang.includes(hash)) {
        location.href = window.location.pathname + '#ru';
    }
    for (let key in langArr) {
        let elem = document.querySelector('.lng-'+ key);
        if (elem) {
            elem.textContent = langArr[key][hash];
        }
    }
}
