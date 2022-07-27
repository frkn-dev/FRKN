const credits = document.querySelectorAll('.copy-credits');
const tooltipTitle = window.location.pathname === '/' ? 'Копировать' : 'Copy';
const tooltipMessage = window.location.pathname === '/' ? 'Скопировано' : 'Copied';

credits.forEach(credit => {
    const tooltip = document.createElement('span');
    tooltip.classList.add('copy-credits-tooltip');
    tooltip.innerText = tooltipTitle;

    credit.appendChild(tooltip);

    credit.addEventListener('click', (e) => {
        const text = e.target.innerText;
        const toolTips = document.querySelectorAll('.copy-credits-tooltip');

        toolTips.forEach(item => {
            item.innerText = tooltipTitle;
        })

        navigator.clipboard.writeText(text)
            .then(() => {
                tooltip.innerText = tooltipMessage;
            })
            .catch(err => {
                console.log('Something went wrong', err);
            });
    });
})