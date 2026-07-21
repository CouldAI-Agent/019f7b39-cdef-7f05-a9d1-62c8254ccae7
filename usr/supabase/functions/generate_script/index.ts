import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { topic, niche, length, tone } = await req.json()
    
    if (!topic || !niche || !length || !tone) {
      throw new Error('Missing required fields.')
    }

    const openAiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openAiKey) {
      throw new Error('OpenAI API key not configured.')
    }

    const prompt = `
      You are an expert YouTube scriptwriter. Write a viral YouTube script.
      Topic: ${topic}
      Niche: ${niche}
      Length: ${length} minutes
      Tone: ${tone}

      Return ONLY a valid JSON object with the following keys, no markdown blocks:
      {
        "title": "A viral title",
        "thumbnail_text": "Text for thumbnail",
        "hook": "15-second hook",
        "script": "The main script body",
        "call_to_action": "CTA at the end",
        "seo_description": "SEO friendly description",
        "hashtags": "#hashtag1 #hashtag2"
      }
    `

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${openAiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system', content: 'You are a helpful assistant that outputs only JSON.' },
          { role: 'user', content: prompt }
        ],
        temperature: 0.7,
      }),
    })

    if (!response.ok) {
      const errorData = await response.text()
      throw new Error(`OpenAI API error: ${response.status} - ${errorData}`)
    }

    const data = await response.json()
    let resultJson;
    try {
        resultJson = JSON.parse(data.choices[0].message.content)
    } catch (e) {
        resultJson = { error: "Failed to parse JSON from OpenAI", raw: data.choices[0].message.content }
    }

    return new Response(JSON.stringify(resultJson), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})