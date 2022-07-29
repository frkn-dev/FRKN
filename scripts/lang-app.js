'use strict';
const langSwitch = document.querySelector('.lang-switch');
const allLang = ['ru', 'en'];

document.addEventListener('DOMContentLoaded', getLocalLang)
langSwitch.addEventListener('click', changeLanguage);

function btnLanguageSwitcher() {
    if (langSwitch.textContent === 'Русский') {
        langSwitch.textContent = 'English';
        langSwitch.value = 'ru';
        
    } else if (langSwitch.textContent === 'English'){
        langSwitch.textContent = 'Русский';
        langSwitch.value = 'en';
    }
}

function changeLanguage() {
    btnLanguageSwitcher()
    let lang = langSwitch.value;
    location.href = window.location.pathname + '#' + lang;
    let hash = window.location.hash;
    hash = hash.slice(1);
    if (!allLang.includes(hash)) {
        location.href = window.location.pathname + '#ru';
    }
    saveLocalLang(hash);
    for (let key in langArr) {
        let elem = document.querySelector('.lng-'+ key);
        if (elem) {
            elem.textContent = langArr[key][hash];
        }
    }
}

function saveLocalLang(language) {
    let langs;
    if(localStorage.getItem('langs') === null) {
        langs = [];
    } else {
        langs = JSON.parse(localStorage.getItem('langs'));
    }
    langs.push(language);
    localStorage.setItem('langs', JSON.stringify(langs));
}

function getLocalLang() {
    let langs;
    if (localStorage.getItem('langs') === null) {
        langs = [];
        location.href = window.location.pathname + '#ru';
        langSwitch.textContent = 'English';
        langSwitch.value = 'ru';
    } else {
        langs = JSON.parse(localStorage.getItem('langs'));
        let hash = langs[langs.length - 1];
        if (hash === 'ru'){
            langSwitch.textContent = 'English';
            langSwitch.value = hash;
            location.href = window.location.pathname + '#' + hash;
        } else if (hash === 'en') {
            langSwitch.textContent = 'Русский';
            langSwitch.value = hash;
            location.href = window.location.pathname + '#' + hash;
        }
    }
    langs.forEach(function (language) {
        let hash = langs[langs.length - 1];
        for (let key in langArr) {
            let elem = document.querySelector('.lng-'+ key);
            if (elem) {
                elem.textContent = langArr[key][hash];
            }
        }
    });
}
