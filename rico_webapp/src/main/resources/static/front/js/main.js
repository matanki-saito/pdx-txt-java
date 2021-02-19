const awaitForLoad = target => {
    return new Promise(resolve => { // 処理A
        const listener = resolve;     // 処理B
        target.addEventListener("load", listener, {once: true}); // 処理C
    });
};

const objectToMap = object =>
    Object.entries(object).reduce((l, [k, v]) => l.set(k, v), new Map())

const pdxTxtWebFront = Vue.component('pdx-txt-web-front', {
    data() {
        return {
            pdxtxt: "",
            pdxjson: "",
            errorMessage: "",
            errors: {}
        }
    },

    mounted() {
        const clipboard = new Clipboard('.clipboard');

        clipboard.on('success', function (e) {
            console.info('Action:', e.action);
            console.info('Text:', e.text);
            console.info('Trigger:', e.trigger);

            e.clearSelection();
        });
    },
    computed: {},
    methods: {
        errorReset: function () {
            this.errorMessage = null
            this.errors = {}
        },
        setError: function (error) {
            const {
                simpleMessage,
                statusCode,
                exceptionDetails
            } = error.response.data;

            this.errorMessage = statusCode + ":" + simpleMessage;
            this.errors = objectToMap(exceptionDetails);
        },
        convertJson: async function () {
            await grecaptcha.ready(async () => {
                const tkn = await grecaptcha.execute(RE_CAPTCHA_V3_SITE_KEY, {action: 'homepage'});

                try {
                    const res = await axios.post("/front/convertTxtToJson", {
                        txt: this.pdxtxt,
                        reCaptchaToken: tkn
                    });
                    this.errorReset()
                    this.pdxjson = res.data.json;
                } catch (error) {
                    this.setError(error)
                }
            });
        },
        convertTxt: async function () {
            await grecaptcha.ready(async () => {
                const tkn = await grecaptcha.execute(RE_CAPTCHA_V3_SITE_KEY, {action: 'homepage'});

                try {
                    const res = await axios.post("/front/convertJsonToTxt", {
                        json: this.pdxjson,
                        reCaptchaToken: tkn
                    });
                    this.errorReset()
                    this.pdxtxt = res.data.txt;
                } catch (error) {
                    this.setError(error)
                }
            });
        }
    },
    template: `
    <div class="contents">
      <div class="alert alert-danger" role="alert" v-if="errorMessage">
        <h2>{{errorMessage}}</h2>
        <ul>
          <li v-for="[key, val] in Array.from(errors)">{{key}} : {{val}}</li>
        </ul>
      </div>
      <h1>Pdx txt tool</h1>
        <h2>txt</h2>
        <div>
          <textarea class="form-control" placeholder="paradox txt 10000文字まで" rows="10" v-model="pdxtxt"></textarea>
        </div>
        <div class="input-group" style="width:100%">
            <div class="input-group-prepend">
              <button class="btn btn-primary" type="button" id="button-convert-json" @click="convertJson">↓変換↓</button>
            </div>
            <div class="input-group-append">
                <button class="btn btn-secondary" type="button" id="button-convert-txt" @click="convertTxt">↑変換↑</button>
            </div>
        </div>
        <div>
            <textarea class="form-control" id="exampleFormControlTextarea1" placeholder="json" rows="10" v-model="pdxjson"></textarea>
        </div>      
    </div>
  `
});
