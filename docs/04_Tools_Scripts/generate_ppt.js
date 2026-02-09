const pptxgen = require('pptxgenjs');
const html2pptx = require('./html2pptx');
const path = require('path');

async function createPresentation() {
    console.log('Starting presentation generation...');
    const pptx = new pptxgen();
    pptx.layout = 'LAYOUT_16x9';
    pptx.author = 'DevOps Team';
    pptx.title = 'Ansible Advanced Tutorial';

    const slidesDir = path.join(__dirname, 'ppt_source');
    const files = [
        'slide1.html',
        'slide2.html',
        'slide3.html',
        'slide4.html',
        'slide5.html',
        'slide6.html',
        'slide7.html',
        'slide8.html'
    ];

    for (const file of files) {
        console.log(`Processing ${file}...`);
        const filePath = path.join(slidesDir, file);
        try {
            await html2pptx(filePath, pptx);
        } catch (error) {
            console.error(`Error processing ${file}:`, error);
            require('fs').appendFileSync('error.txt', `Error in ${file}: ${error}\n`);
        }
    }

    const outputFile = path.join(__dirname, 'Ansible_Advanced_Presentation.pptx');
    await pptx.writeFile({ fileName: outputFile });
    console.log(`Presentation created successfully at ${outputFile}`);
}

createPresentation().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
});
